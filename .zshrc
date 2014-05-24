if [[ -z "$TMUX" && ! -z "$PS1" ]];then
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
zstyle :compinstall filename '/home/kim/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
PROMPT="("
RPROMPT=")%~"
#setopt transient_rprompt
setopt magic_equal_subst
setopt list_packed
setopt hist_ignore_dups
setopt share_history

CIM_HOME=/home/kim/.cim; [ -s '/home/kim/.cim/init.sh' ] && . '/home/kim/.cim/init.sh'
export PATH=~/bin:$PATH

# OPAM configuration
. /home/kim/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
