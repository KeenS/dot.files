# Nushell Environment Config File

def colorize [color: string, str: string] {
  echo [(ansi $color) $str (ansi reset)] | str collect
}

def check-status [] {
    if $env.LAST_EXIT_CODE == 0 {
        ""
    } else {
        [
            (colorize red ":$?")
            " "
            $env.LAST_EXIT_CODE
        ]
    }  | str collect
}

def vcs-stuff [] {
    if is-git-repo {
        [
            (colorize red ":vcs")
            " "
            "git"
            (git-branch-status-check)
            (git-stash-count)
        ] | str collect
    } else if is-hg-repo {
         [
             (colorize red :vcs)
             " "
             hg
             " "
             (hg-branch-status-check)
         ] | str collect
    } else if is-pijul-repo {
        [
            (colorize red :vcs)
            " "
            pijul
            " "
            (pijul-channel-status-check)
        ] | str collect
    }
}

def is-git-repo [] {
    (do -i { git remote }  | complete | get exit_code) == 0
}

def is-hg-repo [] {
    (do -i { hg root } | complete | get exit_code) == 0
}

def is-pijul-repo [] {
    (do -i { pijul remote } | complete | get exit_code) == 0
}

def git-branch-status-check [] {
    let branchname = (do -i {git rev-parse --abbrev-ref HEAD | str trim })
    if $branchname == "" {
        ""
    } else {
        let color = (git-get-branch-status)
        echo [" " (colorize red :branch) " " (colorize $color $branchname)] | str collect
    }
}

def git-get-branch-status [] {
    let workdir = (git diff --quiet | complete | get exit_code) ;
    let index = (git diff --cached --quiet | complete | get exit_code) ;
    if $workdir == 0 && $index == 0 {
        "white"
    } else if $workdir == 1 {
        "red"
    } else {
        # implies $index = 1
        "green"
    }
}

def git-stash-count [] {
    let count = (do -i { git stash list | wc -l | str trim | into int })
    if 0 < $count {
        echo [" " (colorize red :stashes) " " $count] | str collect
    } else {
        ""
    }
}

def hg-branch-status-check [] {
    let branchname = (do -i { hg branch } | str trim)
    if $branchname == "" {
        ""
    } else {
        let prefix = (hg-get-branch-status)
        [(colorize red :branch) " " $branchname] | str collect
    }
}

def hg-get-branch-status [] {
    let workdir = (hg status -m -d | wc -l)
    let index = (hg status -a -r | wc -l)
    if $workdir == 0 && $index == 0 {
        "white"
    } else if $workdir == 1 {
        "red"
    } else {
        # implies $index = 1
        "green"
    }
}

def pijul-channel-status-check [] {
    let channelname = (do -i { pijul channel } | sed -n '/^\*/{s/^\* //;p;q}' | str trim)
    if $channelname == "" {
        ""
    } else {
        let prefix = (pijul-get-channel-status)
        [(colorize red :channel) " " $channelname] | str collect
    }
}

def pijul-get-channel-status [] {
    let workdir = (pijul diff -s | wc -l | into int)
    if $workdir == 0 {
        "white"
    } else {
        "red"
    }
}

def create_left_prompt [] {
    $""
}

def create_right_prompt [] {
    let status = (check-status)
    let vcs = (vcs-stuff)
    let cwd = ([(colorize red :cwd) " " $env.PWD] | str collect)
    [(ansi reset) $status " " $vcs " " $cwd] | str collect
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = { "〉" }
let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = { "〉" }
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = ([
    ($nu.config-path | path dirname | path join 'scripts')
    (glob ($nu.config-path | path dirname | path join 'scripts/nu_scripts/*'))
    (glob ($nu.config-path | path dirname | path join 'scripts/nu_scripts/custom-completions/*'))
] | flatten)

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | prepend '/some/path')
