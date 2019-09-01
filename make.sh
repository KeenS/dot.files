#!/bin/sh
set -e

files="Xmodmap Xresources alacritty.yml stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc gdbinit gdb-dashboard gemrc gitconfig keysnail.js uim.d"

verbose(){
	echo "$@"
	"$@"
}

for f in $files; do
    echo "installing $f"
    verbose ln -sf $(pwd)/$f ~/.$f
done

cat versions | while read name version; do
    echo "installing $name"
    ./install-${name}.sh $version
done
