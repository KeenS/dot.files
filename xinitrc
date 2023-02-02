#!/bin/sh

export LANG=ja_JP.UTF-8
export XIM="fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

export XMODIFIERS="@im=fcitx"
[ -f ~/.xprofile ] && . ~/.xprofile
exec /usr/local/bin/startkde4
