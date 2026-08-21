# Silence meddling functions
function fish_command_not_found
end
function fish_greeting
end

# Environment Variables
if which batcat > /dev/null 2>&1
    set -gx MANPAGER "sh -c 'col -bx | batcat -l man -p'"
end
set -gx MANROFFOPT "-c"
#set -gx XDG_CONFIG_DIRS $HOME/.config
# set -gx XDG_DATA_DIRS /usr/local/share/:/usr/share/
set -gx EDITOR hx
set -gx GOPATH ~/Go
set -gx WASMTIME_HOME "$HOME/.wasmtime"
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx NVM_DIR "$HOME/.nvm"

# PATH
fish_add_path ~/bin
fish_add_path ~/.cabal/bin
fish_add_path $HOME/.smackage/bin
fish_add_path $PATSHOME/bin
fish_add_path $GOPATH/bin
fish_add_path $HOME/.local/bin
fish_add_path $WASMTIME_HOME/bin
fish_add_path $PYENV_ROOT/bin
fish_add_path $HOME/.npm-global/bin
fish_add_path /home/shun/.cache/lm-studio/bin
fish_add_path ~/.cargo/bin

# Tool Initializations
if test -d $PYENV_ROOT
    pyenv init - fish | source
end

# --- Functions ---

function romaji
    echo "$argv[1]" | kakasi -iutf8 -Ha -Ja -Ka -Ea -ka | tr -c '[0-9a-zA-Z\n]' _
end

function open_in_emacs
    emacsclient --no-wait $argv[1]; or setsid emacs $argv[1]
    xdotool search --name --desktop 0 emacs windowactivate
end

function new_post
    set -l title $argv[1]
    set -l title_roman (romaji $title)
    set -l file "post/$title_roman.md"
    hugo new $file
    sed -i "s/$title_roman/$title/I" "content/$file"
    open_in_emacs "content/$file"
end

function new_slide
    set -l title $argv[1]
    set -l title_roman (romaji $title)
    set -l file "slide/$title_roman.md"
    hugo new $file
    sed -i "s/$title_roman/$title/I;s/{{ .Page.Titile }}/$title/I" "content/$file"
    open_in_emacs "content/$file"
end

function import_pdf
    set -l title $argv[1]
    set -l title_roman (romaji $title)
    set -l file "slide/$title_roman/index.md"
    set -l pdf_file "slide/$title_roman/" (basename $argv[2])
    hugo new -k pdf $file
    cp $argv[2] "content/$pdf_file"
    sed -i "s/TITLE/$title/" "content/$file"
    sed -i "s|PDF_PATH|(basename $argv[2])|" "content/$file"
    open_in_emacs "content/$file"
end


function net_tools_deprecated_message
    echo -n 'net-tools commands are obsolete. '
end

function arp
    net_tools_deprecated_message
    echo 'Use `ip n`'
end

function ifconfig
    net_tools_deprecated_message
    echo 'Use `ip a`, `ip link`, `ip -s link`'
end

function iptunnel
    net_tools_deprecated_message
    echo 'Use `ip tunnel`'
end

function iwconfig
    echo -n 'iwconfig is obsolete. '
    echo 'Use `iw`'
end

function nameif
    net_tools_deprecated_message
    echo 'Use `ip link`, `ifrename`'
end

function netstat
    net_tools_deprecated_message
    echo 'Use `ss`, `ip route` (for netstat -r), `ip -s link` (for netstat -i), `ip maddr` (for netstat -g)'
end

function route
    net_tools_deprecated_message
    echo 'Use `ip r`'
end

function new-script
    printf "\
#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   \$0 -- {one sentence description}

SYNOPSIS:
  \$0 [-h|--help]
  \$0 [--verbose]

DESCRIPTION:
   {description here}

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

EXAMPLE:
  {examples if any}

HELP
}

main() {
    SCRIPT_DIR=\"\$(cd \$(dirname \"\$0\"); pwd)\"

    while [ \$# -gt 0 ]; do
        case \"\$1\" in
            --help) usage; exit 0;;
            --verbose) set -x; shift;;
            --) shift; break;;
            -*)
                OPTIND=1
                while getopts h OPT \"\$1\"; do
                    case \"\$OPT\" in
                        h) usage; exit 0;;
                    esac
                done
                shift
                ;;
            *) break;;
        esac
    done

    # do something
}

main \"\$@\"
" > $argv[1]
    chmod +x $argv[1]
end


function rust
    set -l toolchain +stable
    if string match -q "+*" $argv[1]
        set toolchain $argv[1]
        set -e argv[1]
    end
    cargo $toolchain play $argv
end

function c
    set -l tmp (mktemp)
    gcc -Wall -Wextra -o $tmp $argv
    set -l st $status
    if test $st -ne 0
        rm $tmp
        return $st
    end
    $tmp
    set -l st2 $status
    rm $tmp
    return $st2
end

function c++
    set -l tmp (mktemp)
    g++ -o $tmp $argv
    set -l st $status
    if test $st -ne 0
        rm $tmp
        return $st
    end
    $tmp
    set -l st2 $status
    rm $tmp
    return $st2
end

function aws_from_file
    set -gx AWS_ACCESS_KEY_ID (cat $argv[1] | sed 1d | cut -d, -f1)
    set -gx AWS_SECRET_ACCESS_KEY (cat $argv[1] | sed 1d | cut -d, -f2)
end

function highlight
    grep --color=always -e ^ -e $argv
end

# --- Aliases ---
alias rusti='evcxr'
alias ec='open_in_emacs'
alias ls='ls --color'
if which rlwrap > /dev/null 2>&1
   alias smlsharp='rlwrap smlsharp'
   alias sml='rlwrap sml'
end
alias bat=batcat
alias fd=fdfind

# --- Prompt ---

function is-git-repo
    which git >/dev/null 2>&1 && git remote >/dev/null 2>&1
end

function is-hg-repo
    which hg >/dev/null 2>&1 && hg root >/dev/null 2>&1
end

function is-pijul-repo
    which pijul >/dev/null 2>&1 && pijul remote >/dev/null 2>&1
end

function git-stash-count
    set -l count (git stash list 2>/dev/null | count)
    if test $count -gt 0
        set_color red
        echo -n ":stashes "
        set_color normal
        echo -n "$count "
    end
end

function git-get-branch-status
    git diff --quiet
    set -l workdir $status
    git diff --cached --quiet
    set -l index $status
    if test $workdir -eq 0 -a $index -eq 0
        set_color white
    else if test $workdir -eq 1
        set_color red
    else
        set_color green
    end
end

function git-branch-status-check
    set -l branchname (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if test -z "$branchname"
        return
    end
    set_color red
    echo -n ":branch "
    git-get-branch-status
    echo -n "$branchname "
    set_color normal
end

function hg-get-branch-status
    set -l workdir (hg status -m -d | count)
    set -l index (hg status -a -r | count)
    if test $workdir -eq 0 -a $index -eq 0
        set_color white
    else if test $workdir -ne 0
        set_color red
    else
        set_color green
    end
end

function hg-branch-status-check
    set -l branchname (hg branch 2>/dev/null)
    if test -z "$branchname"
        return
    end
    set_color red
    echo -n ":branch "
    hg-get-branch-status
    echo -n "$branchname "
    set_color normal
end

function pijul-get-channel-status
    set -l workdir (pijul diff -s | count)
    if test $workdir -eq 0
        set_color white
    else
        set_color red
    end
end

function pijul-channel-status-check
    set -l channelname (pijul channel 2>/dev/null | sed -n '/^\*/{s/^\* //;p;q}')
    if test -z "$channelname"
        return
    end
    set_color red
    echo -n ":branch "
    pijul-get-branch-status
    echo -n "$branchname "
    set_color normal
end

function vcs-stuff
    if is-git-repo
        set_color red
        echo -n ":vcs "
        set_color normal
        echo -n "git "
        git-branch-status-check
        git-stash-count
    else if is-hg-repo
        set_color red
        echo -n ":vcs "
        set_color normal
        echo -n "hg "
        hg-branch-status-check
    else if is-pijul-repo
        set_color red
        echo -n ":vcs "
        set_color normal
        echo -n "pijul "
        pijul-channel-status-check
    end
end

function fish_prompt
    echo -n "("
end

function fish_right_prompt
    set -l last_status $status
    if test $last_status -ne 0
        set_color red
        echo -n ':$? '
        set_color normal
        echo -n "$last_status "
    end

    vcs-stuff

    set_color red
    echo -n ":cwd "
    set_color normal
    echo -n (pwd | sed "s,^$HOME,~,")
    echo -n ")"
end

if status is-interactive
    eval (zellij setup --generate-auto-start fish | string collect)
end