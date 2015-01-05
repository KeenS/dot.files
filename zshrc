#!/usr/local/bin/zsh
# if [[ -z "$TMUX" && ! -z "$PS1" ]];then
#     if tmux list-sessions >& /dev/null; then
#         exec tmux a
#     else
#         exec tmux
#     fi
# fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=1000000
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kim/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
PROMPT="("
RPROMPT='$(check-status $?)$(branch-status-check)$(colorize red :cwd) %~)'
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
    #prefix=`get-branch-status` #色だけ返ってくる
    #suffix='%{'${reset_color}'%}'
    echo "$(colorize red :branch) ${branchname} "
}
function get-branch-name {
    # gitディレクトリじゃない場合のエラーは捨てます
    echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
}
function get-branch-status {
    local res color
    output=`git status --short 2> /dev/null`
    if [ -z "$output" ]; then
        res=':' # status Clean
        color='%{'${fg[green]}'%}'
    elif [[ $output =~ "[\n]?\?\? " ]]; then
        res='?:' # Untracked
        color='%{'${fg[yellow]}'%}'
    elif [[ $output =~ "[\n]? M " ]]; then
        res='M:' # Modified
        color='%{'${fg[red]}'%}'
    else
        res='A:' # Added to commit
        color='%{'${fg[cyan]}'%}'
    fi
    # echo ${color}${res}'%{'${reset_color}'%}'
    echo ${color} # 色だけ返す
}

net_tools_deprecated_message () {
  echo -n 'net-tools commands are obsolete. '
}

# arp () {
#   net_tools_deprecated_message
#   echo 'Use `ip n`'
# }
# ifconfig () {
#   net_tools_deprecated_message
#   echo 'Use `ip a`, `ip link`, `ip -s link`'
# }
# iptunnel () {
#   net_tools_deprecated_message
#   echo 'Use `ip tunnel`'
# }
# iwconfig () {
#   echo -n 'iwconfig is obsolete. '
#   echo 'Use `iw`'
# }
# nameif () {
#   net_tools_deprecated_message
#   echo 'Use `ip link`, `ifrename`'
# }
# netstat () {
#   net_tools_deprecated_message
#   echo 'Use `ss`, `ip route` (for netstat -r), `ip -s link` (for netstat -i), `ip maddr` (for netstat -g)'
# }
# route () {
#   net_tools_deprecated_message
#   echo 'Use `ip r`'
# }

alias smlsharp_docker='sudo docker.io run -v /home/kim/Sml:/mnt -i -t mzpi/smlsharp bash'
alias ec='emacsclient'
alias ls='ls -G'
export PATH=~/bin:$PATH
export MANPATH=/usr/local/share/man:/usr/share/man/

CIM_HOME=/home/kim/.cim; [ -s '/home/kim/.cim/init.sh' ] && . '/home/kim/.cim/init.sh'

# OPAM configuration
. /home/kim/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true