#!/usr/bin/zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=1000000
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
fpath+=~/.zfunc
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

prompt_default() {
    PROMPT="("
    RPROMPT='$(check-status $?)$(vcs-stuff)$(colorize red :cwd) %~)'
}

prompt_demo() {
    PROMPT="$ "
    unset RPROMPT
}

prompt_default

setopt prompt_subst
setopt transient_rprompt
# {{{ methods for RPROMPT
# fg[color]表記と$reset_colorを使いたい
# @see https://wiki.archlinux.org/index.php/zsh
autoload -U colors; colors

#setopt transient_rprompt
setopt magic_equal_subst
setopt list_packed
setopt hist_ignore_dups
setopt share_history

colorize() {
    echo "%{${fg[$1]}%}$2%{${reset_color}%}"
}

check-status() {
    if [ ! $1 -eq 0 ];then
        echo "$(colorize red :\$\?) $1 "
    else
        echo ""
    fi
}

vcs-stuff() {
    if is-git-repo; then
        echo "$(colorize red :vcs) git $(git-branch-status-check)$(git-stash-count)"
    elif is-hg-repo; then
        echo "$(colorize red :vcs) hg $(hg-branch-status-check)"
    elif is-pijul-repo; then
        echo "$(colorize red :vcs) pijul $(pijul-channel-status-check)"
    fi
}

is-git-repo() {
    git remote >& /dev/null
}

is-hg-repo() {
     hg root >& /dev/null
}

is-pijul-repo() {
    pijul remote >& /dev/null
}


git-stash-count() {
  local COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 0 ]; then
    echo "$(colorize red :stashes) $COUNT "
  fi
}

git-branch-status-check() {
    local prefix branchname suffix
    branchname="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
    # ブランチ名が無いので除外
    if [[ -z $branchname ]]; then
        return
    fi
    prefix=`git-get-branch-status` #色だけ返ってくる
    suffix='%{'${reset_color}'%}'
    echo "$(colorize red :branch) ${prefix}${branchname}${suffix} "
}

git-get-branch-status() {
    local res color workdir index
    git diff --quiet
    workdir=$?
    git diff --cached --quiet
    index=$?
    if [ "$workdir" = 0 ] && [ "$index" = 0 ]; then
        color='%{'${fg[white]}'%}'
    elif [ "$workdir" = 1 ]; then
        color='%{'${fg[red]}'%}'
    else # implies $index = 1 
        color='%{'${fg[green]}'%}'
    fi
    echo ${color} # 色だけ返す
}

hg-branch-status-check() {
    local prefix branchname suffix
    branchname="$(hg branch 2> /dev/null)"
    # ブランチ名が無いので除外
    if [[ -z $branchname ]]; then
        return
    fi
    prefix=`hg-get-branch-status` #色だけ返ってくる
    suffix='%{'${reset_color}'%}'
    echo "$(colorize red :branch) ${prefix}${branchname}${suffix} "
}
hg-get-branch-status() {
    local res color workdir index
    workdir="$(hg status -m -d | wc -l)"
    index="$(hg status -a -r | wc -l)"
    if [ "$workdir" = 0 ] && [ "$index" = 0 ]; then
        color='%{'${fg[white]}'%}'
    elif [ "$workdir" != 0 ]; then
        color='%{'${fg[red]}'%}'
    else # implies $index != 10
        color='%{'${fg[green]}'%}'
    fi
    echo ${color} # 色だけ返す
}

pijul-channel-status-check() {
    local prefix channelname suffix
    channelname="$(pijul channel | sed -n '/^\*/{s/^\* //;p;q}'  2> /dev/null)"
    # ブランチ名が無いので除外
    if [[ -z $channelname ]]; then
        return
    fi
    prefix=`pijul-get-channel-status` #色だけ返ってくる
    suffix='%{'${reset_color}'%}'
    echo "$(colorize red :branch) ${prefix}${channelname}${suffix} "
}
pijul-get-channel-status() {
    local res color workdir index
    workdir="$(pijul diff -s | wc -l)"
    if [ "$workdir" = 0 ] ; then
        color='%{'${fg[white]}'%}'
    else # implies workdir != 0
        color='%{'${fg[red]}'%}'
    fi
    echo ${color} # 色だけ返す
}


net_tools_deprecated_message () {
  echo -n 'net-tools commands are obsolete. '
}

romaji() {
    echo "$1" |  kakasi -iutf8 -Ha -Ja -Ka -Ea -ka | tr -c '[0-9a-zA-Z\n]' _
}

open_in_emacs() {
    # try emacs client
    emacsclient --no-wait "$1" || setsid emacs "$1"
    xdotool search --name --desktop 0 emacs windowactivate
}

new_post() {
    local title="$1"
    local title_roman="$(romaji "$title")"
    local file="post/${title_roman}.md"
    hugo new "$file"
    sed -i "s/$title_roman/$title/I" "content/$file"
    open_in_emacs "content/$file"
}

new_slide() {
    local title="$1"
    local title_roman="$(romaji "$title")"
    local file="slide/${title_roman}.md"
    hugo new "$file"
    sed -i "s/$title_roman/$title/I;s/{{ .Page.Titile }}/$title/I" "content/$file"
    open_in_emacs "content/$file"
}

import_pdf() {
    local title="$1"
    local title_roman="$(romaji "$title")"
    local file="slide/${title_roman}/index.md"
    local pdf_file="slide/${title_roman}/$(basename $2)"
    hugo new -k pdf "$file"
    cp "$2" "content/$pdf_file"
    sed -i "s/TITLE/$title/" "content/$file"
    sed -i "s|PDF_PATH|$(basename $2)|" "content/$file"
    open_in_emacs "content/$file"
}

drill-start() {
    sudo ~/compile/zookeeper-3.4.8/bin/zkServer.sh start
    drillbit.sh start
}

drill-stop() {
    drillbit.sh stop
}

drill-cli() {
    sqlline -u jdbc:drill:zk=localhost:2181
}

drill-web() {
   firefox http://localhost:8047
}

arp () {
  net_tools_deprecated_message
  echo 'Use `ip n`'
}
ifconfig () {
  net_tools_deprecated_message
  echo 'Use `ip a`, `ip link`, `ip -s link`'
}
iptunnel () {
  net_tools_deprecated_message
  echo 'Use `ip tunnel`'
}
iwconfig () {
  echo -n 'iwconfig is obsolete. '
  echo 'Use `iw`'
}
nameif () {
  net_tools_deprecated_message
  echo 'Use `ip link`, `ifrename`'
}
netstat () {
  net_tools_deprecated_message
  echo 'Use `ss`, `ip route` (for netstat -r), `ip -s link` (for netstat -i), `ip maddr` (for netstat -g)'
}
route () {
  net_tools_deprecated_message
  echo 'Use `ip r`'
}

new-script() {
    cat <<'SHELLSCRIPT' > "$1"
#!/bin/sh
# templated by http://qiita.com/blackenedgold/items/c9e60e089974392878c8
usage() {
    cat <<HELP
NAME:
   $0 -- {one sentence description}

SYNOPSIS:
  $0 [-h|--help]
  $0 [--verbose]

DESCRIPTION:
   {description here}

  -h  --help      Print this help.
      --verbose   Enables verbose mode.

EXAMPLE:
  {examples if any}

HELP
}

main() {
    SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

    while [ $# -gt 0 ]; do
        case "$1" in
            --help) usage; exit 0;;
            --verbose) set -x; shift;;
            --) shift; break;;
            -*)
                OPTIND=1
                while getopts h OPT "$1"; do
                    case "$OPT" in
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

main "$@"

SHELLSCRIPT
    chmod +x "$1"
}

nomad_log() {
    if [ $# = 3 ]; then
        if [ "$1" = err ]; then
            set - stderr "$2" "$3"
        elif [ "$1" = out ]; then
            set - stdout "$2" "$3"
        else
            echo "Unknown output type" >&2
            return 1
        fi
    else
        set - stdout "$1" "$2"
    fi
        nomad status "$2" |
            grep Allocations -A 2 |
            tail -n 1 |
            awk '{print $1}' |
            xargs -I@ nomad fs cat @ "alloc/logs/${3}.${1}.0"
}


rust() {
    local toolchain=+stable

    if [[ "$1" =~ "\+.+" ]]; then
        toolchain="$1"
        shift
    fi
    cargo "$toolchain" play "$@"
}

alias rusti="evcxr"

c() {
    local tmp st
    tmp=$(mktemp)

    gcc -Wall -Wextra -o "$tmp" "$@"
    st="$?"
    if [ "$st" != 0 ]; then
        rm "$tmp"
        return "$st"
    fi

    "$tmp"
    st="$?"
    rm "$tmp"
    return "$st"
}

c++() {
    local tmp st
    tmp=$(mktemp)

    g++ -o "$tmp" "$@"
    st="$?"
    if [ "$st" != 0 ]; then
        rm "$tmp"
        return "$st"
    fi

    "$tmp"
    st="$?"
    rm "$tmp"
    return "$st"
}

aws_from_file() {
    export AWS_ACCESS_KEY_ID="$(cat "$1" | sed 1d | cut -d, -f1 )"
    export AWS_SECRET_ACCESS_KEY="$(cat "$1" | sed 1d | cut -d, -f2 )"
}

uutils() {
    export PATH="/opt/uutils/bin:$PATH"
    fpath+=/opt/uutils/share/zsh/site-functions
}

coreutils() {
    export PATH="$(echo "$PATH" | sed 's|/opt/uutils/bin:||')"
    fpath=("${(@)fpath:#/opt/uutils/share/zsh/site-functions}")
}

highlight() {
    grep --color=always -e ^ -e "$@"
}

alias ec='open_in_emacs'
alias ls='ls --color'
alias smlsharp='rlwrap smlsharp'
alias sml='rlwrap sml'
alias bat=batcat
alias fd=fdfind
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
export MANROFFOPT="-c"
export XDG_CONFIG_DIRS=$HOME/.config
export XDG_DATA_DIRS=/usr/local/share/:/usr/share/
export EDITOR=hx

# locals
export PATH=~/bin:$PATH

# Haskell
export PATH=~/.cabal/bin:$PATH

# SML
export PATH=$HOME/.smackage/bin:$PATH

# ATS
ATS_VERSION=0.2.5

export PATSHOME=~/compile/ATS2-Postiats-$ATS_VERSION/
export PATH=$PATSHOME/bin:$PATH
export PATSHOMERELOC=~/compile/ATS2-Postiats-contrib-$ATS_VERSION

# Rust
source $HOME/.cargo/env

# OCaml
. $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# Go
export GOPATH=~/Go
export PATH=$GOPATH/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# use uutils for dog fooding
# export PATH=/opt/uutils/bin:$PATH
# export MAHTPATH=/opt/uutils/man:$(manpath)

# WASM
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Idris2
export PATH="$HOME/.pack/bin:$PATH"

