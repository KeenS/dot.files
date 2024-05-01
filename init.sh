set -e
LANG=C xdg-user-dirs-gtk-update
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

sudo add-apt-repository ppa:inkscape.dev/stable
sudo add-apt-repository ppa:maveonair/helix-editor

sudo apt install \
  zsh \
  git \
  curl \
  fcitx5 fcitx5-skk skkdic skkdic-extra skktools \
  python3-pip \
  build-essential cmake pkg-config libtree-sitter-dev libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev autoconf texinfo libgif-dev libtiff-dev libjpeg-dev libpng-dev libxpm-dev libgtk-3-dev libgnutls28-dev libtinfo-dev kakasi libcurl4-openssl-dev \
  xdotool \
  ripgrep fd-find bat helix \
  yubico-piv-tool yubioath-desktop scdaemon \
  inkscape gnome-calendar \
  gnome-shell-extension-manager
for p in bitwarden blender gimp obs-studio spotify
do
  sudo snap install $p
done

# TODO: install discord slack dropbox from the official site

chsh -s /usr/bin/zsh

sudo groupadd -f uinput
sudo usermod -aG uinput "$USER"
