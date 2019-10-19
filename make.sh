#!/bin/sh
set -e

files="Xmodmap Xresources alacritty.yml stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc gdbinit gdb-dashboard gemrc gitconfig keysnail.js uim.d"

verbose(){
	echo "$@"
	"$@"
}

for f in $files; do
    echo "installing $f"
    verbose ln -Tsf $(pwd)/$f ~/.$f
done

verbose mkdir -p ~/.config/Code/User
verbose ln -Tsf $(pwd)/settings.json ~/.config/Code/User/settings.json

mkdir -p ~/bin
cat versions | while read name version; do
    echo "installing $name"
    ./install-${name}.sh $version
done
