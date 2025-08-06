'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'
() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return
  SPROMPT="%F{249}Correct: %F{4}%R%f %F{249}-> %F{2}%r%F{249} [nyae]? %f"
  PS2="%F{25}❭ %f"
  PS3='?# '
  PS4='%F{23}+%F{25}%N:%i:%_>%F{-1} '
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    neg
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    direnv                  # direnv status (https://direnv.net/)
    asdf                    # asdf version manager (https://github.com/asdf-vm/asdf)
    virtualenv              # python virtual environment (https://docs.python.org/3/library/venv.html)
    anaconda                # conda environment (https://conda.io/)
    pyenv                   # python environment (https://github.com/pyenv/pyenv)
    goenv                   # go environment (https://github.com/syndbg/goenv)
    nodenv                  # node.js version from nodenv (https://github.com/nodenv/nodenv)
    nvm                     # node.js version from nvm (https://github.com/nvm-sh/nvm)
    nodeenv                 # node.js environment (https://github.com/ekalinin/nodeenv)
    # node_version          # node.js version
    # go_version            # go version (https://golang.org)
    # rust_version          # rustc version (https://www.rust-lang.org)
    # dotnet_version        # .NET version (https://dotnet.microsoft.com)
    # php_version           # php version (https://www.php.net/)
    # laravel_version       # laravel php framework version (https://laravel.com/)
    # java_version          # java version (https://www.java.com/)
    # package               # name@version from package.json (https://docs.npmjs.com/files/package.json)
    rbenv                   # ruby version from rbenv (https://github.com/rbenv/rbenv)
    rvm                     # ruby version from rvm (https://rvm.io)
    fvm                     # flutter version management (https://github.com/leoafarias/fvm)
    luaenv                  # lua version from luaenv (https://github.com/cehoffman/luaenv)
    jenv                    # java version from jenv (https://github.com/jenv/jenv)
    plenv                   # perl version from plenv (https://github.com/tokuhirom/plenv)
    perlbrew                # perl version from perlbrew (https://github.com/gugod/App-perlbrew)
    phpenv                  # php version from phpenv (https://github.com/phpenv/phpenv)
    scalaenv                # scala version from scalaenv (https://github.com/scalaenv/scalaenv)
    haskell_stack           # haskell version from stack (https://haskellstack.org/)
    kubecontext             # current kubernetes context (https://kubernetes.io/)
    terraform               # terraform workspace (https://www.terraform.io)
    # terraform_version     # terraform version (https://www.terraform.io)
    aws                     # aws profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
    aws_eb_env              # aws elastic beanstalk environment (https://aws.amazon.com/elasticbeanstalk/)
    azure                   # azure account name (https://docs.microsoft.com/en-us/cli/azure)
    gcloud                  # google cloud cli account and project (https://cloud.google.com/)
    google_app_cred         # google application credentials (https://cloud.google.com/docs/authentication/production)
    toolbox                 # toolbox name (https://github.com/containers/toolbox)
    context                 # user@hostname
    nordvpn                 # nordvpn connection status, linux only (https://nordvpn.com/)
    ranger                  # ranger shell (https://github.com/ranger/ranger)
    nnn                     # nnn shell (https://github.com/jarun/nnn)
    lf                      # lf shell (https://github.com/gokcehan/lf)
    xplr                    # xplr shell (https://github.com/sayanarijit/xplr)
    vim_shell               # vim shell indicator (:sh)
    midnight_commander      # midnight commander shell (https://midnight-commander.org/)
    nix_shell               # nix shell (https://nixos.org/nixos/nix-pills/developing-with-nix-shell.html)
    # vpn_ip                # virtual private network indicator
    # load                  # CPU load
    # disk_usage            # disk usage
    # ram                   # free RAM
    # swap                  # used swap
    # todo                  # todo items (https://github.com/todotxt/todo.txt-cli)
    # timewarrior           # timewarrior tracking status (https://timewarrior.net/)
    # taskwarrior           # taskwarrior task count (https://taskwarrior.org/)
    # cpu_arch              # CPU architecture
    # time                  # current time
    # ip                    # ip address and bandwidth usage for a specified network interface
    # public_ip             # public IP address
    # proxy                 # system-wide http/https/ftp proxy
    # battery               # internal battery
    # wifi                  # wifi speed
    # example               # example user-defined segment (see prompt_example function below)
    vcs                     # git status
  )
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent background
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no surrounding whitespace
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '  # separate segments with a space
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=        # no end-of-line symbol
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_RULER_CHAR='─'        # reasonable alternative: '·'
  typeset -g POWERLEVEL9K_RULER_FOREGROUND=242
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=242
    typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=' '
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=25
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=24
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=103
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=39
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-version
    .shorten_folder_marker
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH='40%'
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_LOCK_ICON=''
  typeset -g POWERLEVEL9K_DIR_CLASSES=()
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi
    if (( $1 )); then
      # Styling for up-to-date Git status.
      local meta='%f'           # default foreground
      local clean='%249F'       # green foreground
      local modified='%63F'     # yellow foreground
      local untracked='%30F'    # violet foreground
      local conflicted='%196F'  # red foreground
      local new='%26F'          # blue foreground
    else
      # Styling for incomplete and stale Git status.
      local meta='%244F'       # grey foreground
      local clean='%244F'      # grey foreground
      local modified='%244F'   # grey foreground
      local untracked='%244F'  # grey foreground
      local conflicted='%244F' # grey foreground
      local new='%244F'        # grey foreground
    fi
    local res
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"  # <-- this line
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi
    if [[ -n $VCS_STATUS_TAG
          && -z $VCS_STATUS_LOCAL_BRANCH  # <-- this line
        ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"  # <-- this line
      res+="${meta}#${clean}${tag//\%/%%}"
    fi
    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&  # <-- this line
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"
    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi
    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi
    (( VCS_STATUS_COMMITS_BEHIND )) && res+="${clean}←${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=""
    (( VCS_STATUS_COMMITS_AHEAD )) && res+="${new}→${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=""
    (( VCS_STATUS_PUSH_COMMITS_AHEAD )) && res+=" ${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    [[ -n $VCS_STATUS_ACTION ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED )) && res+=" ${modified}◈${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED )) && res+="${modified}∙${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+="${modified}─"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=24
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=244
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION='❮'
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=74
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=74
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=70
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_ERROR=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=97
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=70
  typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=178
  typeset -g POWERLEVEL9K_ASDF_FOREGROUND=66
  typeset -g POWERLEVEL9K_ASDF_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_ASDF_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_ASDF_SHOW_ON_UPGLOB=
  typeset -g POWERLEVEL9K_ASDF_RUBY_FOREGROUND=24
  typeset -g POWERLEVEL9K_ASDF_PYTHON_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_GOLANG_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_NODEJS_FOREGROUND=70
  typeset -g POWERLEVEL9K_ASDF_RUST_FOREGROUND=37
  typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_FOREGROUND=134
  typeset -g POWERLEVEL9K_ASDF_FLUTTER_FOREGROUND=38
  typeset -g POWERLEVEL9K_ASDF_LUA_FOREGROUND=32
  typeset -g POWERLEVEL9K_ASDF_JAVA_FOREGROUND=32
  typeset -g POWERLEVEL9K_ASDF_PERL_FOREGROUND=67
  typeset -g POWERLEVEL9K_ASDF_ERLANG_FOREGROUND=125
  typeset -g POWERLEVEL9K_ASDF_ELIXIR_FOREGROUND=129
  typeset -g POWERLEVEL9K_ASDF_POSTGRES_FOREGROUND=31
  typeset -g POWERLEVEL9K_ASDF_PHP_FOREGROUND=99
  typeset -g POWERLEVEL9K_ASDF_HASKELL_FOREGROUND=172
  typeset -g POWERLEVEL9K_ASDF_JULIA_FOREGROUND=70
  typeset -g POWERLEVEL9K_NORDVPN_FOREGROUND=39
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=
  typeset -g POWERLEVEL9K_RANGER_FOREGROUND=178
  typeset -g POWERLEVEL9K_NNN_FOREGROUND=72
  typeset -g POWERLEVEL9K_LF_FOREGROUND=72
  typeset -g POWERLEVEL9K_XPLR_FOREGROUND=72
  typeset -g POWERLEVEL9K_VIM_SHELL_FOREGROUND=34
  typeset -g POWERLEVEL9K_MIDNIGHT_COMMANDER_FOREGROUND=178
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND=74
  typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND=35
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND=220
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND=160
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
  typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=66
  typeset -g POWERLEVEL9K_SWAP_FOREGROUND=96
  typeset -g POWERLEVEL9K_LOAD_WHICH=5
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND=66
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND=178
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND=166
  typeset -g POWERLEVEL9K_TODO_FOREGROUND=110
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL=true
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED=false
  typeset -g POWERLEVEL9K_TIMEWARRIOR_FOREGROUND=110
  typeset -g POWERLEVEL9K_TIMEWARRIOR_CONTENT_EXPANSION='${P9K_CONTENT:0:24}${${P9K_CONTENT:24}:+…}'
  typeset -g POWERLEVEL9K_TASKWARRIOR_FOREGROUND=74
  typeset -g POWERLEVEL9K_CPU_ARCH_FOREGROUND=172
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=178
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=180
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=37
  typeset -g POWERLEVEL9K_ANACONDA_CONTENT_EXPANSION='${${${${CONDA_PROMPT_MODIFIER#\(}% }%\)}:-${CONDA_PREFIX:t}}'
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='${P9K_CONTENT}${${P9K_CONTENT:#$P9K_PYENV_PYTHON_VERSION(|/*)}:+ $P9K_PYENV_PYTHON_VERSION}'
  typeset -g POWERLEVEL9K_GOENV_FOREGROUND=37
  typeset -g POWERLEVEL9K_GOENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_GOENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_NODENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_NODENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_NVM_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION=false
  typeset -g POWERLEVEL9K_NODEENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_DOTNET_VERSION_FOREGROUND=134
  typeset -g POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PHP_VERSION_FOREGROUND=99
  typeset -g POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_LARAVEL_VERSION_FOREGROUND=161
  typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=32
  typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_JAVA_VERSION_FULL=false
  typeset -g POWERLEVEL9K_PACKAGE_FOREGROUND=117
  typeset -g POWERLEVEL9K_RBENV_FOREGROUND=24
  typeset -g POWERLEVEL9K_RBENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_RBENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_RVM_FOREGROUND=24
  typeset -g POWERLEVEL9K_RVM_SHOW_GEMSET=false
  typeset -g POWERLEVEL9K_RVM_SHOW_PREFIX=false
  typeset -g POWERLEVEL9K_FVM_FOREGROUND=38
  typeset -g POWERLEVEL9K_LUAENV_FOREGROUND=32
  typeset -g POWERLEVEL9K_LUAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_LUAENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_JENV_FOREGROUND=32
  typeset -g POWERLEVEL9K_JENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_JENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PLENV_FOREGROUND=67
  typeset -g POWERLEVEL9K_PLENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PLENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_PERLBREW_FOREGROUND=67
  typeset -g POWERLEVEL9K_PERLBREW_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PERLBREW_SHOW_PREFIX=false
  typeset -g POWERLEVEL9K_PHPENV_FOREGROUND=99
  typeset -g POWERLEVEL9K_PHPENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PHPENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_SCALAENV_FOREGROUND=160
  typeset -g POWERLEVEL9K_SCALAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_SCALAENV_SHOW_SYSTEM=true
  typeset -g POWERLEVEL9K_HASKELL_STACK_FOREGROUND=172
  typeset -g POWERLEVEL9K_HASKELL_STACK_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_HASKELL_STACK_ALWAYS_SHOW=true
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=134
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
      '*'         OTHER)
  typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND=38
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_FOREGROUND=38
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AWS_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=208
  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'
  typeset -g POWERLEVEL9K_AWS_EB_ENV_FOREGROUND=70
  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AZURE_FOREGROUND=32
  typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gcs|gsutil'
  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND=32
  typeset -g POWERLEVEL9K_GCLOUD_PARTIAL_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_COMPLETE_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_NAME//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_REFRESH_PROJECT_NAME_SECONDS=60
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_SHOW_ON_COMMAND='terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES=(
      '*'             DEFAULT)
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_FOREGROUND=32
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_CONTENT_EXPANSION='${P9K_GOOGLE_APP_CRED_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_TOOLBOX_FOREGROUND=178
  typeset -g POWERLEVEL9K_TOOLBOX_CONTENT_EXPANSION='${P9K_TOOLBOX_NAME:#fedora-toolbox-*}'
  typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND=94
  typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=81
  typeset -g POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'
  typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false
  typeset -g POWERLEVEL9K_IP_FOREGROUND=38
  typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='$P9K_IP_IP${P9K_IP_RX_RATE:+ %70F⇣$P9K_IP_RX_RATE}${P9K_IP_TX_RATE:+ %215F⇡$P9K_IP_TX_RATE}'
  typeset -g POWERLEVEL9K_IP_INTERFACE='[ew].*'
  typeset -g POWERLEVEL9K_PROXY_FOREGROUND=68
  typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
  typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND=160
  typeset -g POWERLEVEL9K_BATTERY_{CHARGING,CHARGED}_FOREGROUND=70
  typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND=178
  typeset -g POWERLEVEL9K_BATTERY_STAGES='\uf58d\uf579\uf57a\uf57b\uf57c\uf57d\uf57e\uf57f\uf580\uf581\uf578'
  typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false
  typeset -g POWERLEVEL9K_WIFI_FOREGROUND=68
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
  typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
  function instant_prompt_neg() {
      prompt_neg
  }
  function prompt_neg() {
    setopt sh_word_split
    full_path="$PWD"
    mainc="%(?.%F{4}.%F{4})"
    tildac="%(?.%F{2}.%F{4})"
    prompt_end=" %F{25}❯%B%F{26}>%B%f"
    neg_user_pretok="%f"
    [[ ${UID} -ne 0 ]] && _neg_promptcolor="${tildac}" && _neg_user_pretoken="${mainc}%f"
    [[ ${UID} -ne 0 ]] && _neg_promptcolor="${tildac}" && _neg_user_token="${mainc}${prompt_end}"
    dyn_pwd=""
    tilda_path=${full_path/${HOME}/\~}
    # write the home directory as a tilda
    [[ ${tilda_path[2,-1]} == "/" ]] && tilda_path=${tilda_path[2,-1]}
    # otherwise the first element of split_path would be empty.
    forward_tilda=${tilda_path//[^["\/"]/}
    # remove everything that is not a "/"
    neg_num=$(( $#forward_tilda + 1 ))
    # we removed the first forward slash, so we need one more element than the number of slashes
    IFS_="${IFS}"
    IFS="/"
    _neg_split_path=(${tilda_path})
    _neg_start_of_loop=1
    _neg_end_of_loop=${neg_num}
    for i in {$_neg_start_of_loop..$_neg_end_of_loop}; do
        if [[ $i == $_neg_end_of_loop ]]; then
          to_be_added=$_neg_split_path[i]'/'
          dyn_pwd=${dyn_pwd}${to_be_added}
        else
          to_be_added=${_neg_split_path[i]}
          to_be_added=${to_be_added}"%F{4}/%F{249}"
          dyn_pwd=${dyn_pwd}${to_be_added}
        fi
    done
    IFS=${IFS_}
    [[ ${full_path/${HOME}/\~} != ${full_path} ]] && dyn_pwd=${dyn_pwd/\/~/~}
    # remove the slash in front of ${HOME}
    neg_prompt="%F${_neg_promptcolor}${dyn_pwd[0,-2]}%F{0}$_neg_user_token%b%k%f"
    if [[ $full_path = $HOME ]]; then
      p10k segment -f 25 -t "${prompt_end}"
    else
      p10k segment -f 25 -t " ${neg_user_pretok}%f%40<..<${neg_prompt}"
    fi
  }
  function instant_prompt_example() {
    prompt_example
  }
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
