{-# LANGUAGE OverloadedStrings, RecordWildCards, FlexibleContexts #-}

import Control.Monad (forM_, when, unless, void, filterM)
import Control.Monad.IO.Class (liftIO)
import Data.Char (isDigit, isSpace)
import Data.List (isPrefixOf, isSuffixOf, intercalate, sort, nub, find)
import Data.Maybe (fromMaybe, catMaybes, mapMaybe)
import Data.Time.Clock (UTCTime, getCurrentTime, diffUTCTime, NominalDiffTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import System.Directory (getHomeDirectory, createDirectoryIfMissing, 
                         getModificationTime, doesFileExist, doesDirectoryExist,
                         getXdgDirectory, XdgDirectory(..))
import System.Environment (getArgs, getEnv, lookupEnv)
import System.FilePath (takeDirectory, (</>), takeFileName)
import System.Exit (exitFailure, ExitCode(..))
import System.IO (hPutStrLn, stderr, IOMode(..), stdin, stdout, stderr, hSetBuffering, BufferMode(..),
             hSetBuffering, BufferMode(..), hGetContents, hClose, hPutStr)
import System.Process (readProcess, callCommand, readProcessWithExitCode, 
                   createProcess, waitForProcess, proc, std_in, std_out, std_err,
                   StdStream(..), CreateProcess(..))
import Data.Map (Map)
import qualified Data.Map as Map
import Options.Applicative
import System.Posix.Terminal (queryTerminal)
import System.Posix.IO (stdInput)

-- Конфигурация
data Config = Config {
    clearPlaylist :: Bool,
    mode :: Mode,
    verbose :: Bool,
    noCache :: Bool,
    dbPath :: Maybe FilePath
} deriving Show

data Mode = ArtistMode | DirectoryMode | ArtistAlbumMode deriving (Eq, Show)

-- Модель данных
data Song = Song {
    artist :: Maybe String,
    album :: Maybe String,
    date :: Maybe String,
    filePath :: String
} deriving (Show, Read)

-- Парсер аргументов командной строки
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
        <> help "Specify MPD database path explicitly"))

readMode :: ReadM Mode
readMode = eitherReader $ \s -> case s of
    "artist" -> Right ArtistMode
    "directory" -> Right DirectoryMode
    "artist-album" -> Right ArtistAlbumMode
    _ -> Left $ "Unknown mode: " ++ s

modeToStr :: Mode -> String
modeToStr ArtistMode = "artist"
modeToStr DirectoryMode = "directory"
modeToStr ArtistAlbumMode = "artist-album"

-- Поиск файла базы данных MPD
getMPDDatabasePath :: Bool -> IO FilePath
getMPDDatabasePath verboseMode = do
    mConfPath <- findConfigWithPS verboseMode
    case mConfPath of
        Just confPath -> parseConfig confPath verboseMode
        Nothing -> do
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

-- Поиск конфига через ps aux | awk
findConfigWithPS :: Bool -> IO (Maybe FilePath)
findConfigWithPS verboseMode = do
    (exitCode, out, err) <- readProcessWithExitCode "sh" 
        ["-c", "ps aux | grep -v grep | grep -E 'mpd\\s+.*mpd\\.conf' | awk '{print $NF}' | head -1"] ""
    
    when verboseMode $ putStrLn $ "PS AUX output: " ++ out
    
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

-- Удаление кавычек и пробелов
cleanPath :: String -> String
cleanPath = unwords . words . filter (\c -> c `notElem` ("\"'" :: String))

-- Извлечение пути к БД из конфига
parseConfig :: FilePath -> Bool -> IO FilePath
parseConfig confPath verboseMode = do
    when verboseMode $ putStrLn $ "Parsing MPD config: " ++ confPath
    
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

-- Чтение песен из tag_cache
getSongs :: FilePath -> IO [Song]
getSongs dbPath = do
    let tagCachePath = takeDirectory dbPath </> "tag_cache"
    when (verboseDebug) $ putStrLn $ "Reading tag_cache from: " ++ tagCachePath
    content <- readFile tagCachePath
    return $ parseTagCache content
  where
    verboseDebug = False
    
    parseTagCache :: String -> [Song]
    parseTagCache content = 
        let blocks = splitBlocks $ lines content
        in mapMaybe parseBlock blocks
    
    -- Разделяем содержимое на блоки песен
    splitBlocks :: [String] -> [[String]]
    splitBlocks [] = []
    splitBlocks lines' = 
        case dropWhile (not . isBlockStart) lines' of
            [] -> []
            (start:rest) -> 
                let (block, remaining) = break isBlockEnd rest
                in (start : block) : splitBlocks (drop 1 remaining)  -- drop "end"
    
    isBlockStart :: String -> Bool
    isBlockStart s = "begin: " `isPrefixOf` s
    
    isBlockEnd :: String -> Bool
    isBlockEnd s = s == "end"
    
    -- Парсим блок песни
    parseBlock :: [String] -> Maybe Song
    parseBlock [] = Nothing
    parseBlock (fileLine:tags) 
        | "begin: " `isPrefixOf` fileLine = 
            let beginPrefix = "begin: " :: String
                filePath = drop (length beginPrefix) fileLine
                tagMap = parseTags tags
            in Just $ Song {
                artist = Map.lookup "Artist" tagMap,
                album = Map.lookup "Album" tagMap,
                date = Map.lookup "Date" tagMap,
                filePath = filePath
            }
        | otherwise = Nothing
    
    -- Парсим теги в блоке
    parseTags :: [String] -> Map.Map String String
    parseTags tags = 
        Map.fromList $ mapMaybe parseTag tags
    
    parseTag :: String -> Maybe (String, String)
    parseTag line
        | "tag: " `isPrefixOf` line = 
            let tagPrefix = "tag: " :: String
                content = drop (length tagPrefix) line
                (key, value) = break (== ':') content
            in if not (null value) 
                then Just (key, dropWhile isSpace $ drop 1 value)
                else Nothing
        | otherwise = Nothing

-- Обработка данных
processArtistMode :: [Song] -> [String]
processArtistMode songs = 
    sort $ nub $ catMaybes [artist s | s <- songs]

processDirectoryMode :: [Song] -> [String]
processDirectoryMode songs = 
    sort $ nub $ map (takeDirectory . filePath) songs

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

extractYear :: Song -> Maybe String
extractYear song = 
    case date song of
        Just d -> 
            let text = d
            in case take 4 $ filter isDigit text of
                [y1,y2,y3,y4] | all isDigit [y1,y2,y3,y4] -> Just [y1,y2,y3,y4]
                _ -> Nothing
        _ -> Nothing

-- Кэширование
getCacheDir :: IO FilePath
getCacheDir = do
    dir <- getXdgDirectory XdgCache "mpd_manager"
    createDirectoryIfMissing True dir
    return dir

getCacheFile :: Mode -> IO FilePath
getCacheFile m = do
    dir <- getCacheDir
    return $ dir </> modeToStr m ++ ".cache"

loadCache :: Mode -> FilePath -> UTCTime -> IO (Maybe [String])
loadCache mode dbPath now = do
    cacheFile <- getCacheFile mode
    cacheExists <- doesFileExist cacheFile
    if not cacheExists
        then return Nothing
        else do
            cacheModTime <- getModificationTime cacheFile
            dbModTime <- getModificationTime dbPath
            let cacheFresh = diffUTCTime now cacheModTime < 86400 -- 24 часа
                cacheValid = cacheModTime > dbModTime
            if cacheFresh && cacheValid
                then Just . lines <$> readFile cacheFile
                else return Nothing

saveCache :: Mode -> [String] -> IO ()
saveCache mode cacheData = do
    cacheFile <- getCacheFile mode
    writeFile cacheFile (unlines cacheData)

-- Обработка песен в зависимости от режима
processSongs :: Mode -> [Song] -> [String]
processSongs mode songs = case mode of
    ArtistMode -> processArtistMode songs
    DirectoryMode -> processDirectoryMode songs
    ArtistAlbumMode -> processArtistAlbumMode songs

-- Взаимодействие с MPD
clearMPDPlaylist :: IO ()
clearMPDPlaylist = callCommand "mpc clear > /dev/null"

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

playMPD :: IO ()
playMPD = callCommand "mpc play > /dev/null"

-- Утилиты FZF с гарантированным отображением
runFZF :: Bool -> Mode -> [String] -> IO [String]
runFZF verboseMode mode items = do
    when verboseMode $ do
        putStrLn $ "FZF: processing " ++ show (length items) ++ " items"
    
    -- Проверка доступности терминала
    isTerminal <- queryTerminal stdInput
    unless isTerminal $ do
        hPutStrLn stderr "Error: Input is not a terminal. fzf requires interactive terminal."
        exitFailure
    
    -- Проверка наличия fzf
    (fzfExit, _, fzfErr) <- readProcessWithExitCode "fzf" ["--version"] ""
    when (fzfExit /= ExitSuccess) $ do
        hPutStrLn stderr $ "fzf not found or not working: " ++ fzfErr
        exitFailure
    
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
    
    -- Используем createProcess для прямого подключения stdio
    (Just inHandle, Just outHandle, Just errHandle, processHandle) <-
        createProcess (proc "fzf" args) { std_in = CreatePipe, std_out = CreatePipe, std_err = CreatePipe }
    
    -- Записываем данные в stdin fzf
    hPutStr inHandle (unlines items)
    hClose inHandle
    
    -- Читаем вывод
    output <- hGetContents outHandle
    errors <- hGetContents errHandle
    
    -- Ждем завершения
    exitCode <- waitForProcess processHandle
    
    when verboseMode $ do
        putStrLn $ "FZF exit code: " ++ show exitCode
        putStrLn $ "FZF stderr: " ++ errors
    
    case exitCode of
        ExitSuccess -> return $ filter (not . null) $ lines output
        _ -> do
            when (not (null errors)) $ hPutStrLn stderr $ "fzf error: " ++ errors
            return []

-- Основной поток
main :: IO ()
main = do
    hSetBuffering stdout LineBuffering
    config <- execParser $ info (argsParser <**> helper) fullDesc
    
    -- Получаем путь к базе данных
    dbPath' <- case dbPath config of
        Just path -> return path
        Nothing -> getMPDDatabasePath (verbose config)
    
    when (verbose config) $ do
        putStrLn $ "Using database: " ++ dbPath'
    
    -- Вычисляем путь к tag_cache
    let tagCachePath = takeDirectory dbPath' </> "tag_cache"
    
    -- Проверяем, что файл tag_cache существует
    exists <- doesFileExist tagCachePath
    unless exists $ do
        hPutStrLn stderr $ "tag_cache file not found: " ++ tagCachePath
        exitFailure
    
    now <- getCurrentTime
    
    let currentMode = mode config
    
    -- Получение данных
    choices <- if noCache config 
        then do
            songs <- getSongs dbPath'
            return $ processSongs currentMode songs
        else do
            mcache <- loadCache currentMode tagCachePath now
            case mcache of
                Just cached -> return cached
                Nothing -> do
                    songs <- getSongs dbPath'
                    let choices = processSongs currentMode songs
                    saveCache currentMode choices
                    return choices
    
    when (verbose config) $ do
        putStrLn $ "Loaded " ++ show (length choices) ++ " choices"
        when (length choices < 20) $ mapM_ putStrLn choices
    
    -- Запускаем fzf только если есть что выбирать
    selected <- if null choices
        then do
            hPutStrLn stderr "No items available for selection."
            return []
        else runFZF (verbose config) currentMode choices
    
    when (clearPlaylist config) clearMPDPlaylist
    
    start <- getCurrentTime
    totalAdded <- sum <$> mapM (addToMPDPlaylist currentMode) selected
    
    playMPD
    
    end <- getCurrentTime
    totalCount <- getPlaylistCount
    
    let duration = realToFrac (diffUTCTime end start) :: Double
    putStrLn $ "🎵 Updated in " ++ showDuration duration
    putStrLn $ "🚀 Tracks added: " ++ show totalAdded
    putStrLn $ "📋 Total in playlist: " ++ show totalCount ++ " tracks"
  where
    showDuration d
        | d < 1     = show (round (d * 1000)) ++ "ms"
        | otherwise = show (round d) ++ "s"
    
    getPlaylistCount = length . lines <$> readProcess "mpc" ["playlist"] ""
