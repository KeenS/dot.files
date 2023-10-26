LANG=C xdg-user-dirs-gtk-update
gsettings set org.gnome.desktop.input-sources xkb-options ['ctrl:nocaps']

sudo add-apt-repository ppa:inkscape.dev/stable
sudo add-apt-repository ppa:maveonair/helix-editor

sudo apt install zsh git curl uim-skk skkdic skkdic-extra python3-pip build-essential cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev autoconf texinfo libgif-dev libtiff-dev libjpeg-dev libpng-dev libxpm-dev libgtk-3-dev libgnutls28-dev libtinfo-dev kakasi libcurl4-openssl-dev skktools gnome-tweak-tool network-manager-l2tp-gnome xdotool exa ripgrep fd-find bat inkscape
sudo snap install bitwarden blender discord gimp obs-studio slack spotify helix

chsh -s /usr/bin/zsh

sudo groupadd -f uinput
sudo usermod -aG uinput "$USER"
