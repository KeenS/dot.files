#!/bin/sh

export LANG=ja_JP.UTF-8
export XIM="uim-xim"
export GTK_IM_MODULE=uim
export QT_IM_MODULE=uim

/usr/local/bin/uim-xim &
/usr/local/bin/uim-toolbar-gtk &

export XMODIFIERS="@im=uim"
[ -f ~/.xprofile ] && . ~/.xprofile
exec /usr/local/bin/startkde4
