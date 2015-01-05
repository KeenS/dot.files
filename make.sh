#!/bin/sh

files="Xmodmap Xresources stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc"

verbose(){
	echo "$@"
	"$@"
}

for f in $files; do
	verbose ln -sf $(pwd)/$f ~/.$f 
done

