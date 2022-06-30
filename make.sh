#!/bin/sh
set -e

files="Xmodmap Xresources alacritty.yml stumpwmrc tmux.conf xinitrc zshrc xprofile hgrc gdbinit gdb-dashboard gemrc gitconfig keysnail.js uim.d"

verbose(){
	echo "$@"
	"$@"
}

firefox_pref_relpath() {
    python3 -c "import configparser;c = configparser.ConfigParser();c.read('$firefox_home/profiles.ini');[print(c[s]['Path']) for s in c.sections() if 'Default' in c[s] and c[s]['Default'] == '1' ]"
}

install_link() {
    if ! [ -s $2 ]; then
        echo "installing $(basename "$1")"
        verbose ln -Tsf "$1" "$2"
    fi
}

for f in $files; do
    install_link "$(pwd)/$f" "$HOME/.$f"
done

verbose mkdir -p ~/.config/Code/User
install_link "$(pwd)/settings.json" ~/.config/Code/User/settings.json

verbose mkdir -p ~/.docker
install_link "$(pwd)/docker_config.json" ~/.docker/config.json

verbose mkdir -p ~/.config/zellij
install_link "$(pwd)/zellij.yaml" ~/.config/zellij/config.yaml

verbose mkdir -p ~/.config/
install_link "$(pwd)/nushell" ~/.config/nushell

firefox_home="$HOME/.mozilla/firefox"
firefox_prefdir="$firefox_home/$(firefox_pref_relpath)"

install_link "$(pwd)/user.js" "$firefox_prefdir"/user.js

verbose mkdir -p ~/.config/inkscape/
for f in preferences.xml pages.csv template; do
    install_link "$(pwd)/inkscape/$f" "$HOME/.config/inkscape/$f"
done

install_link "$(pwd)/xremap.service" ~/.config/systemd/user/xremap.service

mkdir -p ~/bin

cat versions | while read name version; do
    echo "installing $name"
    ./install-${name}.sh $version
done
