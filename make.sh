#!/bin/sh

files="Xmodmap Xresources stumpwmrc tmux.conf xinitrc zshrc xprofile"

verbose(){
	echo "$@"
	"$@"
}

for f in $files; do
	verbose ln -sf $(pwd)/$f ~/.$f 
done

