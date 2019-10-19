#!/bin/sh
set -e

files="Xmodmap Xresources alacritty.yml stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc gdbinit gdb-dashboard gemrc gitconfig keysnail.js uim.d"

verbose(){
	echo "$@"
	"$@"
}

install_link() {
    if ! [ -s $2 ]; then
        echo "installing $(basename "$1")"
        verbose ln -Tsf "$1" "$2"
    fi
}

for f in $files; do
    install_link "$(pwd)/$f" "~/.$f"
done

verbose mkdir -p ~/.config/Code/User
install_link "$(pwd)/settings.json" ~/.config/Code/User/settings.json


mkdir -p ~/bin

cat versions | while read name version; do
    echo "installing $name"
    ./install-${name}.sh $version
done
