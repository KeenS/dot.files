#!/bin/sh

files="Xmodmap Xresources alacritty.yml stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc gdbinit gdb-dashboard gemrc gitconfig keysnail.js uim.d"

verbose(){
	echo "$@"
	"$@"
}

for f in $files; do
	verbose ln -sf $(pwd)/$f ~/.$f 
done

cat versions | while read name version; do
    ./install_${name}.sh $version
done
