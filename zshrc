#!/usr/local/bin/zsh
if [ -z "$TMUX" ] && [ -z "$STY" ] ;then
    if tmux list-sessions >& /dev/null; then
        exec tmux a
    else
        exec tmux
    fi
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=1000000
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

prompt_default() {
    PROMPT="("
    RPROMPT='$(check-status $?)$(branch-status-check)$(stash-count)$(colorize red :cwd) %~)'
}

prompt_demo() {
    PROMPT="$ "
    unset RPROMPT
}

prompt_default

setopt prompt_subst

# {{{ methods for RPROMPT
# fg[color]表記と$reset_colorを使いたい
# @see https://wiki.archlinux.org/index.php/zsh
autoload -U colors; colors

#setopt transient_rprompt
setopt magic_equal_subst
setopt list_packed
setopt hist_ignore_dups
setopt share_history

function colorize {
    echo "%{${fg[$1]}%}$2%{${reset_color}%}"
}

function check-status {
    if [ ! $1 -eq 0 ];then
        echo "$(colorize red :\$\?) $1 "
    else
        echo ""
    fi
}

function stash-count {
  local COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 0 ]; then
    echo "$(colorize red :stashes) $COUNT "
  fi
}

function branch-status-check {
    local prefix branchname suffix
    # .gitの中だから除外
    if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
        return
    fi
    branchname=`get-branch-name`
    # ブランチ名が無いので除外
    if [[ -z $branchname ]]; then
        return
    fi
    prefix=`get-branch-status` #色だけ返ってくる
    suffix='%{'${reset_color}'%}'
    echo "$(colorize red :branch) ${prefix}${branchname}${suffix} "
}
function get-branch-name {
    # gitディレクトリじゃない場合のエラーは捨てます
    echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
}
function get-branch-status {
    local res color workdir index
    git diff --quiet
    workdir=$?
    git diff --cached --quiet
    index=$?
    if [ "$workdir" = 0 ] && [ "$index" = 0 ]; then
        res=':' # status Clean
        color='%{'${fg[white]}'%}'
    elif [ "$workdir" = 1 ]; then
        res='M:' # Modified
        color='%{'${fg[red]}'%}'
    else # implies $index = 1 
        res='A:' # Added to commit
        color='%{'${fg[green]}'%}'
    fi
    # echo ${color}${res}'%{'${reset_color}'%}'
    echo ${color} # 色だけ返す
}

net_tools_deprecated_message () {
  echo -n 'net-tools commands are obsolete. '
}

romaji() {
    echo "$1" |  kakasi -iutf8 -Ha -Ja -Ka -Ea -ka | tr -c '[0-9a-zA-Z\n]' _
}

new_post() {
    local title="$1"
    local title_roman="$(romaji "$title")"
    local file="post/${title_roman}.md"
    hugo new "$file"
    sed -i "s/$title_roman/$title/I" "content/$file"
    emacsclient --no-wait "content/$file"
}

new_slide() {
    local title="$1"
    local title_roman="$(romaji "$title")"
    local file="slide/${title_roman}.md"
    hugo new "$file"
    sed -i "s/$title_roman/$title/I;s/{{ .Page.Titile }}/$title/I" "content/$file"
    emacsclient --no-wait "content/$file"
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
    cargo "$toolchain" script "$@"
}

c() {
    local tmp st
    tmp=$(mktemp)

    gcc -o "$tmp" "$@"
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

alias ec='emacsclient'
alias ls='ls --color'
alias smlsharp='rlwrap smlsharp'
export PATH=/usr/local/bin/:~/bin:~/.cabal/bin:$PATH
export XDG_CONFIG_DIRS=$HOME/.config
export XDG_DATA_DIRS=/usr/local/share/:/usr/share/
export EDITOR=vi
{ CIM_HOME=$HOME/.cim; [ -s "$CIM_HOME/init.sh" ] && . "$CIM_HOME/init.sh" } || true

ATS_VERSION=0.2.5

export PATSHOME=~/compile/ATS2-Postiats-$ATS_VERSION/
export PATH=$PATSHOME/bin:$PATH
export PATSHOMERELOC=~/compile/ATS2-Postiats-contrib-$ATS_VERSION

source $HOME/.cargo/env

# OPAM configuration
. $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true


export GOPATH=~/Go
export PATH=$GOPATH/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# use uutils for dog fooding
#export PATH=/opt/uutils/bin:$PATH

export PYTHONPATH=$env:"/opt/movidius/caffe/python":$PYTHONPATH
