local o=vim.opt
local env_=vim.env
local home_=env_.HOME
local config_home_=env_.XDG_CONFIG_HOME
o.sessionoptions='blank,buffers,curdir,folds,help,tabpages,winsize'
-- thx to https://www.reddit.com/r/neovim/comments/opipij/guide_tips_and_tricks_to_reduce_startup_and/
local disabled_built_ins={
    '2html_plugin',
    'bugreport',
    'compiler',
    'did_load_filetypes',
    'ftplugin',
    'getscript',
    'getscriptPlugin',
    'gzip',
    'logipat',
    'matchit',
    'matchparen',
    'node_provider',
    'optwin',
    'perl_provider',
    'python3_provider',
    'rplugin',
    'rrhelper',
    'ruby_provider',
    'spellfile_plugin',
    'synmenu',
    'syntax',
    'tar',
    'tarPlugin',
    'tutor',
    'vimball',
    'vimballPlugin',
    'zip',
    'zipPlugin',
}
for _, plugin in pairs(disabled_built_ins) do
    vim.g['loaded_'..plugin]=1
end
-- netrw is disabled elsewhere; drop redundant globals
if vim.fn.executable('ugrep') == 1 then
    o.grepprg='ugrep -RInk -j -u --tabs=1 --ignore-files'
    o.grepformat='%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\|%l\\|%c\\|%m'
end
if vim.fn.executable('nvr') == 1 then
    env_.GIT_EDITOR="nvr -cc split +'setl bh=delete' --remote-wait"
    env_.EDITOR='nvr -l --remote'
    env_.VISUAL='nvr -l --remote'
end
o.path='.,..,'..config_home_..'/nvim,'..
    	config_home_..'/nvim/lua,'..
	config_home_..'/nvim/after,'..
	home_..'/.local/share/nvim/site/,/usr/include'
o.fillchars={foldopen="", foldclose="",
    fold=" ", foldsep=" ",
    diff="╱", eob=" "}
o.formatprg='par -140'                       -- Better format
o.report=0                                   -- No report on substitution
o.fileformats='unix,dos,mac'                 -- File format fallback
o.conceallevel=1                             -- Enable conceal without hide
o.concealcursor='n'                          -- Conceal cursor
o.keymap='russian-jcukenwin'                 -- Add ru keymap
o.backup=true                                -- Backuping is good
o.cedit='<C-y>'                              -- Enter Command-line Mode from command-mode
o.clipboard='unnamedplus'                    -- Always clipboard all operations
o.cindent=true                               -- Smart indenting for c-like code
o.cinoptions='b1,g0,N-s,t0,(0,W4'            -- See :h cinoptions-values
o.copyindent=true                            -- Copy the previous indentation on autoindenting
o.diffopt='internal,filler,closeoff,algorithm:patience,indent-heuristic' -- Use the indent heuristic for the internal diff library.
o.eadirection='hor'                          -- Ver/hor/both - where does equalalways apply
o.expandtab=true                             -- Tabs are spaces=not tabs
o.fileencodings='utf-8,default'              -- Less file encodings
o.gdefault=true                              -- This makes search/replace global by default
o.ignorecase=true                            -- Case insensitive search
o.imsearch=0                                 -- Search with latin1 characters first
o.isfname='#,$,%,+,,,-,.,/,48-57,=,@,_,~,@-@'  -- Scan in filenames in such brackets
o.matchtime=0                                -- Default time to hi brackets too long for me
o.matchpairs='(:),{:},[:],<:>'                 -- More matchpairs
o.foldenable=false                           -- Disable folds as
o.numberwidth=3                              -- Shorter number width
o.signcolumn='yes:1'                         -- Merge sign and numbers
o.pumblend=15                                -- setup pmenu transparency
o.pumheight=10                               -- Do not make pmenu too wide
o.scrolljump=0                               -- Lines to scroll when cursor leaves screen
o.scrollback=1                               -- Disable scrollback
o.shiftwidth=4                               -- Spaces for autoindents
o.termguicolors=true                         -- Enable termguicolors
o.wildignorecase=true                        -- Ignore case for wildmenu
o.wildignore='*.7z,*.aux,*.avi,*.bak,*.bib,*.class,*.cls,*.cmi,'..
    '*.cmo,*.doc,*.docx,*.dvi,*.flac,*.flv,*.gif,*.ico,'..
    '*.jpeg,*.jpg,*.log,*.min*.js,*.mov,*.mp3,*.mp4,*.mpg,'..
    '*.nav,*.o,*.ods,*.odt,*.ogg,*.opus,*.out,*.pdf,*.pem,'..
    '*.png,*.rar,*.sty,*.svg,*.swp,*.swp*.,*.tar,*.tgz,'..
    '*.toc,*.wav,*.webm,*.xcf,*.xls,*.xlsx,*.zip'
o.shortmess='OcsliFtfnToAIqx'                  -- Shorting messages for all
o.more=false                                 -- Do not ask to press enter
o.showmode=false                             -- Do not show the mode ("-- INSERT --" at the bottom)
o.showcmd=false                              -- Do not show command output
o.showtabline=0                              -- Do not show tab line
o.smartcase=true                             -- Case sensitive when uc present
o.softtabstop=4                              -- Let backspace delete indent
o.splitbelow=true                            -- Puts new split windows to the bottom of the current
o.splitright=true                            -- Puts new vsplit windows to the right of the current
o.switchbuf='useopen,usetab'                 -- useopen may be useful for re-using QuickFix window.
o.tabstop=4                                  -- An indentation every four columns
o.timeoutlen=400                             -- 400 ms wait to sequence complete
o.ttimeoutlen=20                             -- Very fast and also you shouldnt make combination too fast
o.updatetime=100                             -- Faster diagnostics
o.redrawtime=1500                            -- Shorter redrawtime
o.virtualedit='onemore,block'                -- Allow for cursor beyond last character
o.whichwrap='b,s,h,l,<,>,[,]'                -- Backspace and cursor keys wrap too
o.wildoptions={'pum'}                        -- Wild options
o.winblend=15                                -- Pseudo-transparency for floating windows
o.winminheight=0                             -- Windows can be 0 line high
o.winminwidth=0                              -- Windows can be 0 line width
o.wrap=false                                 -- Do not wrap lines by default
o.mouse='a'                                  -- Add mouse support
o.mousescroll={'ver:2','hor:1'}              -- More conservative mouse scroll
o.backupdir=home_..'/trash/'               -- Setup backupdir
o.directory=home_..'/trash/'               -- Directory for swap files
o.undodir=home_..'/trash/'                 -- Setup undo dir
o.undofile=true                              -- Enable undofile
o.swapfile=false                             -- Do not use swapfiles
o.shada=[['20,<50,s5,h]]                     -- Ultra fast shada settings
o.cdhome=true                                -- :cd without argument goes to the home directory
o.completeopt='menu,menuone,noselect'        -- Completion options
o.formatoptions='n1jcroqlj'                  -- Format settings
o.cpoptions='_$ABFWcdesa'                    -- Vim-exclusive stuff
o.ruler=false                                -- No ruler
o.cmdheight=0                                -- Fancy cmdheight for neovim
o.laststatus=3                               -- One statusline for all
