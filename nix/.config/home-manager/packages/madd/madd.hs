{-# LANGUAGE OverloadedStrings, RecordWildCards, FlexibleContexts #-}

-- Import necessary modules
import Control.Monad (forM_, when, unless, void, filterM)
import Control.Monad.IO.Class (liftIO)
import Data.Char (isDigit, isSpace, toUpper)
import Data.List (isPrefixOf, isSuffixOf, intercalate, sort, nub, find)
import Data.Maybe (fromMaybe, catMaybes, mapMaybe)
import Data.Time.Clock (UTCTime, getCurrentTime, diffUTCTime, NominalDiffTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import System.Directory (getHomeDirectory, createDirectoryIfMissing, 
                         getModificationTime, doesFileExist, doesDirectoryExist,
                         getXdgDirectory, XdgDirectory(..))
import System.Environment (getArgs, getEnv, lookupEnv)
import System.FilePath (takeDirectory, (</>), takeFileName)
import System.Process (readProcess, callCommand, readProcessWithExitCode, 
                       createProcess, waitForProcess, proc, std_in, std_out, std_err,
                       StdStream(..), CreateProcess(..))
import System.Exit (exitFailure, ExitCode(..))
import System.IO (hPutStrLn, stderr, IOMode(..), stdin, stdout, stderr, 
                 hSetBuffering, BufferMode(..), hGetContents, hClose, hPutStr)
import Data.Map (Map)
import qualified Data.Map as Map
import Options.Applicative
import System.Posix.Terminal (queryTerminal)
import System.Posix.IO (stdInput)

-- ================================================================
-- Configuration Data Types
-- ================================================================

-- Main configuration options for the program
data Config = Config {
    clearPlaylist :: Bool,   -- Whether to clear playlist before adding
    mode :: Mode,            -- Selection mode (artist, directory, etc)
    verbose :: Bool,         -- Verbose output flag
    noCache :: Bool,         -- Disable caching flag
    dbPath :: Maybe FilePath -- Optional explicit database path
} deriving Show

-- Different selection modes for organizing music
data Mode = ArtistMode | DirectoryMode | ArtistAlbumMode deriving (Eq, Show)

-- Data model representing a song with metadata
data Song = Song {
    artist :: Maybe String,  -- Artist name (if available)
    album :: Maybe String,   -- Album name (if available)
    date :: Maybe String,    -- Release date (if available)
    filePath :: String       -- File system path to the song
} deriving (Show, Read)

-- ================================================================
-- Command Line Argument Parser
-- ================================================================

-- Define command line options parser
argsParser :: Parser Config
argsParser = Config
    <$> switch (
        long "clear" 
        <> short 'c' 
        <> help "Clear playlist before adding")
    <*> option readMode (
        long "mode" 
        <> short 'm' 
        <> metavar "MODE" 
        <> value ArtistAlbumMode 
        <> showDefaultWith modeToStr
        <> help "Selection mode: artist, directory, artist-album")
    <*> switch (
        long "verbose" 
        <> short 'v' 
        <> help "Enable verbose output")
    <*> switch (
        long "no-cache" 
        <> help "Disable caching")
    <*> optional (strOption (
        long "db-path" 
        <> short 'd' 
        <> metavar "PATH" 
        <> help "Specify MPD database or tag_cache path explicitly"))

-- Helper to parse mode string
readMode :: ReadM Mode
readMode = eitherReader $ \s -> case s of
    "artist" -> Right ArtistMode
    "directory" -> Right DirectoryMode
    "artist-album" -> Right ArtistAlbumMode
    _ -> Left $ "Unknown mode: " ++ s

-- Convert mode to string for display
modeToStr :: Mode -> String
modeToStr ArtistMode = "artist"
modeToStr DirectoryMode = "directory"
modeToStr ArtistAlbumMode = "artist-album"

-- ================================================================
-- MPD Database Path Handling
-- ================================================================

-- Find MPD database path through various methods
getMPDDatabasePath :: Bool -> IO FilePath
getMPDDatabasePath verboseMode = do
    -- Try finding config via process list
    mConfPath <- findConfigWithPS verboseMode
    case mConfPath of
        Just confPath -> parseConfig confPath verboseMode
        Nothing -> do
            -- Check standard locations
            home <- getHomeDirectory
            let defaultConfs = [ 
                  home </> ".config/mpd/mpd.conf",
                  home </> ".mpdconf",
                  "/etc/mpd.conf",
                  home </> "mpd/mpd.conf",
                  "/etc/mpd/mpd.conf",
                  home </> ".mpd/mpd.conf",
                  "/usr/local/etc/mpd.conf"]
            when verboseMode $ do
                putStrLn "Searching for MPD config in standard locations:"
                mapM_ (putStrLn . ("- " ++)) defaultConfs
            
            existing <- filterM doesFileExist defaultConfs
            case existing of
                (confPath:_) -> parseConfig confPath verboseMode
                [] -> error $ unlines [
                    "MPD config file not found.",
                    "Tried to find via running processes and in:",
                    unlines (map ("- " ++) defaultConfs),
                    "Specify path with: --db-path /path/to/database"]

-- Find MPD config path by examining running processes
findConfigWithPS :: Bool -> IO (Maybe FilePath)
findConfigWithPS verboseMode = do
    (exitCode, out, err) <- readProcessWithExitCode "sh" 
        ["-c", "ps aux | grep -v grep | grep -E 'mpd\\s+.*mpd\\.conf' | awk '{print $NF}' | head -1"] ""
    
    when verboseMode $ do
        putStrLn $ "PS AUX output: " ++ out
    
    case exitCode of
        ExitSuccess -> case lines out of
            [] -> return Nothing
            (path:_) -> do
                exists <- doesFileExist path
                if exists 
                    then do
                        when verboseMode $ putStrLn $ "Found MPD config via ps: " ++ path
                        return $ Just path
                    else return Nothing
        _ -> return Nothing

-- Clean up path string by removing quotes and extra spaces
cleanPath :: String -> String
cleanPath = unwords . words . filter (\c -> c `notElem` ("\"'" :: String))

-- Parse MPD config file to extract database path
parseConfig :: FilePath -> Bool -> IO FilePath
parseConfig confPath verboseMode = do
    when verboseMode $ do
        putStrLn $ "Parsing MPD config: " ++ confPath
    
    content <- readFile confPath
    let dbLine = findDatabaseLine (lines content)
    
    case dbLine of
        Just line -> extractDbPath line verboseMode
        Nothing -> error $ "Database path not found in MPD config: " ++ confPath
  where
    findDatabaseLine :: [String] -> Maybe String
    findDatabaseLine ls = 
        let nonComments = filter (not . isComment) ls
        in case filter (isPrefixOf "database" . dropWhile isSpace) nonComments of
            (l:_) -> Just l
            [] -> case filter (isPrefixOf "db_file" . dropWhile isSpace) nonComments of
                (l:_) -> Just l
                [] -> Nothing
      where
        isComment :: String -> Bool
        isComment s = case dropWhile isSpace s of
            ('#':_) -> True
            _ -> False
    
    extractDbPath :: String -> Bool -> IO FilePath
    extractDbPath line verboseMode = do
        let cleanLine = takeWhile (/= '#') line
            path = case words cleanLine of
                (_:rest) -> unwords rest
                _ -> ""
            
            cleanPathStr = cleanPath path
        
        when verboseMode $ do
            putStrLn $ "Raw db path from config: " ++ path
            putStrLn $ "Cleaned db path: " ++ cleanPathStr
        
        home <- getHomeDirectory
        let expandedPath = case cleanPathStr of
                '~':'/':rest -> home </> rest
                _ -> cleanPathStr
        
        when verboseMode $ putStrLn $ "Expanded db path: " ++ expandedPath
        return expandedPath

-- ================================================================
-- Tag Cache Parsing
-- ================================================================

-- Read songs from tag_cache file
getSongs :: Bool -> FilePath -> IO [Song]
getSongs verboseMode dbPath' = do
    -- Determine actual tag_cache path (user might specify it directly)
    let tagCachePath = if "tag_cache" `isSuffixOf` dbPath'
                       then dbPath'
                       else takeDirectory dbPath' </> "tag_cache"
    
    when verboseMode $ do
        putStrLn $ "Using tag_cache: " ++ tagCachePath
    
    -- Read and parse the file
    content <- readFile tagCachePath
    let linesCount = length (lines content)
    when verboseMode $ do
        putStrLn $ "Read " ++ show linesCount ++ " lines from tag_cache"
        
        -- Show file samples for debugging
        putStrLn "First 3 lines of tag_cache:"
        forM_ (take 3 $ lines content) $ \line -> 
            putStrLn $ "  " ++ line
        
        when (linesCount > 3) $ do
            putStrLn "Last 3 lines of tag_cache:"
            forM_ (take 3 $ reverse $ lines content) $ \line -> 
                putStrLn $ "  " ++ line
    
    let songs = parseTagCache content
    when verboseMode $ do
        putStrLn $ "Parsed " ++ show (length songs) ++ " songs"
        when (length songs > 0) $ do
            putStrLn "Sample songs:"
            forM_ (take 3 songs) $ \song -> do
                putStrLn $ "  File: " ++ filePath song
                putStrLn $ "    Artist: " ++ show (artist song)
                putStrLn $ "    Album: " ++ show (album song)
                putStrLn $ "    Date: " ++ show (date song)
    return songs
  where
    -- Parse entire tag_cache content into song list
    parseTagCache :: String -> [Song]
    parseTagCache content = 
        let lines' = lines content
            songBlocks = extractSongBlocks lines'
        in mapMaybe parseSongBlock songBlocks

    extractSongBlocks :: [String] -> [[String]]
    extractSongBlocks [] = []
    extractSongBlocks (line:rest)
        | "song_begin" `isPrefixOf` line =  -- Modified condition
            let (block, remaining) = collectBlock ["song_begin"] [] rest
            in block : extractSongBlocks remaining
        | otherwise = extractSongBlocks rest

    -- Collect lines until matching "song_end" is found
    collectBlock :: [String] -> [String] -> [String] -> ([String], [String])
    collectBlock stack current [] = (reverse current, [])
    collectBlock [] current rest = (reverse current, rest)
    collectBlock stack current (line:rest)
        | "song_begin" `isPrefixOf` line =  -- Modified condition
            collectBlock ("song_begin":stack) (line:current) rest
        | line == "song_end" = 
            case stack of
                ("song_begin":xs) -> 
                    if null xs 
                    then (reverse (line:current), rest)  -- Block closed
                    else collectBlock xs (line:current) rest
                _ -> collectBlock stack (line:current) rest
        | otherwise = 
            collectBlock stack (line:current) rest
            
    parseSongBlock :: [String] -> Maybe Song
    parseSongBlock [] = Nothing
    parseSongBlock (firstLine:rest)
        | "song_begin" `isPrefixOf` firstLine =  -- Modified condition
            let pathLine = dropWhile (== ' ') $ dropWhile (/= ' ') firstLine
                filePath = case pathLine of
                    ':':restPath -> restPath  -- Handle colon format
                    _ -> pathLine             -- Handle space format
                tags = parseTagsInBlock rest
            in Just $ Song {
                artist = Map.lookup "ARTIST" tags,
                album = Map.lookup "ALBUM" tags,
                date = Map.lookup "DATE" tags,
                filePath = trim filePath  -- Added trim
            }
        | otherwise = Nothing

    -- Parse tags within a song block
    parseTagsInBlock :: [String] -> Map.Map String String
    parseTagsInBlock lines' = 
        let tagLines = takeWhile (/= "song_end") lines'
        in Map.fromList $ mapMaybe parseTagLine tagLines
    
    -- Parse a single tag line
    parseTagLine :: String -> Maybe (String, String)
    parseTagLine line
        | "tag: " `isPrefixOf` line = 
            let content = drop (length ("tag: " :: String)) line
                parts = splitAtColon content
            in case parts of
                (key, value) | not (null key) -> 
                    Just (map toUpper (trim key), trim value)
                _ -> Nothing
        | otherwise = Nothing

    -- Split string at first colon
    splitAtColon :: String -> (String, String)
    splitAtColon s = 
        case break (== ':') s of
            (key, ':' : rest) -> (key, rest)
            (key, _) -> (key, "")
    
    -- Remove leading/trailing whitespace
    trim :: String -> String
    trim = unwords . words

-- ================================================================
-- Data Processing
-- ================================================================

-- Process songs for artist mode
processArtistMode :: [Song] -> [String]
processArtistMode songs = 
    sort $ nub $ catMaybes [artist s | s <- songs]

-- Process songs for directory mode
processDirectoryMode :: [Song] -> [String]
processDirectoryMode songs = 
    sort $ nub $ map (takeDirectory . filePath) songs

-- Process songs for artist-album mode
processArtistAlbumMode :: [Song] -> [String]
processArtistAlbumMode songs = 
    map formatEntry $ Map.toList albumMap
  where
    albumMap = foldl buildMap Map.empty songs
    buildMap acc song = 
        case (artist song, album song) of
            (Just a, Just b) -> 
                let key = (a, b)
                    year = extractYear song
                in Map.insertWith (\_ old -> min old year) key year acc
            _ -> acc
    formatEntry ((a, b), year) = 
        a ++ " - " ++ b ++ maybe "" (\y -> " [" ++ y ++ "]") year

-- Extract year from date string
extractYear :: Song -> Maybe String
extractYear song = 
    case date song of
        Just d -> 
            let text = d
            in case take 4 $ filter isDigit text of
                [y1,y2,y3,y4] | all isDigit [y1,y2,y3,y4] -> Just [y1,y2,y3,y4]
                _ -> Nothing
        _ -> Nothing

-- ================================================================
-- Caching System
-- ================================================================

-- Get cache directory path
getCacheDir :: IO FilePath
getCacheDir = do
    dir <- getXdgDirectory XdgCache "mpd_manager"
    createDirectoryIfMissing True dir
    return dir

-- Get cache file path for specific mode
getCacheFile :: Mode -> IO FilePath
getCacheFile m = do
    dir <- getCacheDir
    return $ dir </> modeToStr m ++ ".cache"

-- Load cached data if available and fresh
loadCache :: Mode -> FilePath -> UTCTime -> IO (Maybe [String])
loadCache mode dbPath now = do
    cacheFile <- getCacheFile mode
    cacheExists <- doesFileExist cacheFile
    if not cacheExists
        then return Nothing
        else do
            cacheModTime <- getModificationTime cacheFile
            dbModTime <- getModificationTime dbPath
            let cacheFresh = diffUTCTime now cacheModTime < 86400 -- 24 hours
                cacheValid = cacheModTime > dbModTime
            if cacheFresh && cacheValid
                then Just . lines <$> readFile cacheFile
                else return Nothing

-- Save data to cache
saveCache :: Mode -> [String] -> IO ()
saveCache mode cacheData = do
    cacheFile <- getCacheFile mode
    writeFile cacheFile (unlines cacheData)

-- Process songs based on selected mode
processSongs :: Mode -> [Song] -> [String]
processSongs mode songs = case mode of
    ArtistMode -> processArtistMode songs
    DirectoryMode -> processDirectoryMode songs
    ArtistAlbumMode -> processArtistAlbumMode songs

-- ================================================================
-- MPD Interaction
-- ================================================================

-- Clear current MPD playlist
clearMPDPlaylist :: IO ()
clearMPDPlaylist = callCommand "mpc clear > /dev/null"

-- Add item to MPD playlist based on mode
addToMPDPlaylist :: Mode -> String -> IO Int
addToMPDPlaylist mode item = do
    let cmd = case mode of
            ArtistMode -> "mpc findadd artist \"" ++ escape item ++ "\""
            DirectoryMode -> "mpc add \"" ++ escape item ++ "\""
            ArtistAlbumMode -> 
                case parseArtistAlbum item of
                    (artist, album, _) -> "mpc findadd artist \"" ++ escape artist ++ 
                                          "\" album \"" ++ escape album ++ "\""
    before <- getPlaylistCount
    callCommand $ cmd ++ " > /dev/null"
    after <- getPlaylistCount
    return $ after - before
  where
    escape s = "'" ++ s ++ "'"
    getPlaylistCount = length . lines <$> readProcess "mpc" ["playlist"] ""

-- Parse artist-album string from selection
parseArtistAlbum :: String -> (String, String, Maybe String)
parseArtistAlbum s = 
    case break (== '-') s of
        (artistPart, '-':' ':rest) -> 
            let (albumPart, yearPart) = break (== '[') rest
            in ( trim artistPart,
                 trim albumPart,
                 if "[" `isPrefixOf` yearPart 
                    then Just $ takeWhile (/= ']') $ drop 1 yearPart
                    else Nothing )
        (artistPart, rest) -> (trim artistPart, trim rest, Nothing)
  where
    trim = unwords . words

-- Start playback in MPD
playMPD :: IO ()
playMPD = callCommand "mpc play > /dev/null"

-- ================================================================
-- FZF Integration
-- ================================================================

-- Run FZF for interactive selection
runFZF :: Bool -> Mode -> [String] -> IO [String]
runFZF verboseMode mode items = do
    when verboseMode $ do
        putStrLn $ "FZF: processing " ++ show (length items) ++ " items"
    
    -- Check if we're in a terminal
    isTerminal <- queryTerminal stdInput
    unless isTerminal $ do
        hPutStrLn stderr "Error: Input is not a terminal. fzf requires interactive terminal."
        exitFailure
    
    -- Verify fzf is available
    (fzfExit, _, fzfErr) <- readProcessWithExitCode "fzf" ["--version"] ""
    when (fzfExit /= ExitSuccess) $ do
        hPutStrLn stderr $ "fzf not found or not working: " ++ fzfErr
        exitFailure
    
    -- Prepare fzf arguments
    let header = case mode of
            ArtistMode -> "🎤 ARTIST SELECTION"
            DirectoryMode -> "📁 DIRECTORY SELECTION"
            ArtistAlbumMode -> "🎤💿 ARTIST-ALBUM-YEAR SELECTION"
        bindings = [ 
            "--bind", "ctrl-e:execute(echo switch)+abort",
            "--bind", "ctrl-r:reload()",
            "--bind", "ctrl-l:execute(rm -f $HOME/.cache/mpd_manager/*)+reload"]
        args = [ "--multi"
               , "--prompt=Select (" ++ modeToStr mode ++ "): "
               , "--header=" ++ header ++ " [Enter] Add | [Esc] Cancel" ++
                 " [Ctrl+e] Switch mode | [Ctrl+r] Refresh | [Ctrl+l] Clear cache"
               , "--ansi", "--height=60%", "--reverse"
               ] ++ bindings
    
    when verboseMode $ do
        putStrLn $ "FZF arguments: " ++ show args
        putStrLn $ "FZF input count: " ++ show (length items)
    
    -- Configure process with pipes for I/O
    let processSpec = (proc "fzf" args) { 
            std_in = CreatePipe,
            std_out = CreatePipe,
            std_err = CreatePipe 
        }
    (Just inHandle, Just outHandle, Just errHandle, processHandle) <- 
        createProcess processSpec
    
    -- Send items to fzf's stdin
    hPutStr inHandle (unlines items)
    hClose inHandle
    
    -- Capture fzf output
    output <- hGetContents outHandle
    errors <- hGetContents errHandle
    
    -- Wait for fzf to finish
    exitCode <- waitForProcess processHandle
    
    when verboseMode $ do
        putStrLn $ "FZF exit code: " ++ show exitCode
        putStrLn $ "FZF stderr: " ++ errors
    
    -- Return selected items or empty list
    case exitCode of
        ExitSuccess -> return $ filter (not . null) $ lines output
        _ -> do
            when (not (null errors)) $ hPutStrLn stderr $ "fzf error: " ++ errors
            return []

-- ================================================================
-- Main Program Flow
-- ================================================================

main :: IO ()
main = do
    -- Ensure line buffering for proper output
    hSetBuffering stdout LineBuffering
    
    -- Parse command line arguments
    config <- execParser $ info (argsParser <**> helper) fullDesc
    
    -- Get database path (either from flag or auto-detected)
    dbPath' <- case dbPath config of
        Just path -> return path
        Nothing -> getMPDDatabasePath (verbose config)
    
    when (verbose config) $ do
        putStrLn $ "Using database: " ++ dbPath'
    
    -- Verify tag_cache exists
    let tagCachePath = if "tag_cache" `isSuffixOf` dbPath'
                       then dbPath'
                       else takeDirectory dbPath' </> "tag_cache"
    
    exists <- doesFileExist tagCachePath
    unless exists $ do
        hPutStrLn stderr $ "tag_cache file not found: " ++ tagCachePath
        exitFailure
    
    now <- getCurrentTime
    
    let currentMode = mode config
    
    -- Load songs from tag_cache
    songs <- getSongs (verbose config) dbPath'
    
    when (verbose config) $ do
        putStrLn $ "Found " ++ show (length songs) ++ " songs in database"
    
    -- Process songs based on current mode
    let choices = processSongs currentMode songs
    
    when (verbose config) $ do
        putStrLn $ "Processed " ++ show (length choices) ++ " choices"
        when (length choices < 20) $ mapM_ putStrLn choices
    
    -- Run FZF only if we have items to show
    selected <- if null choices
        then do
            hPutStrLn stderr "No items available for selection."
            return []
        else runFZF (verbose config) currentMode choices
    
    -- Clear playlist if requested
    when (clearPlaylist config) clearMPDPlaylist
    
    -- Add selected items to playlist
    start <- getCurrentTime
    totalAdded <- sum <$> mapM (addToMPDPlaylist currentMode) selected
    
    -- Start playback
    playMPD
    
    -- Calculate and display statistics
    end <- getCurrentTime
    totalCount <- getPlaylistCount
    
    let duration = realToFrac (diffUTCTime end start) :: Double
    putStrLn $ "🎵 Updated in " ++ showDuration duration
    putStrLn $ "🚀 Tracks added: " ++ show totalAdded
    putStrLn $ "📋 Total in playlist: " ++ show totalCount ++ " tracks"
  where
    -- Format time duration for display
    showDuration d
        | d < 1     = show (round (d * 1000)) ++ "ms"
        | otherwise = show (round d) ++ "s"
    
    -- Get current playlist count from MPD
    getPlaylistCount = length . lines <$> readProcess "mpc" ["playlist"] ""
