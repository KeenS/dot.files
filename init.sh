set -e
LANG=C xdg-user-dirs-gtk-update
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

sudo add-apt-repository ppa:inkscape.dev/stable
sudo add-apt-repository ppa:maveonair/helix-editor

sudo apt install \
  zsh git curl \
  fcitx5 fcitx5-skk skkdic skkdic-extra skktools \
  python3-pip python3-venv \
  ruby \
  build-essential cmake pkg-config libtree-sitter-dev libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev autoconf texinfo libgif-dev libtiff-dev libjpeg-dev libpng-dev libxpm-dev libgtk-3-dev libgnutls28-dev libtinfo-dev kakasi libcurl4-openssl-dev \
  xdotool \
  ripgrep fd-find bat helix \
  yubico-piv-tool yubioath-desktop scdaemon \
  inkscape gnome-calendar digikam \
  gnome-shell-extension-manager \
  flatpak

for p in bitwarden gimp spotify
do
  sudo snap install $p
done

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
for p in com.obsproject.Studio
do
  sudo flatpak install flathub $p
done

wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

# TODO: install discord slack dropbox keybase from the official site

chsh -s /usr/bin/zsh

# for xremap
sudo groupadd -f uinput
sudo usermod -aG uinput "$USER"
sudo gpasswd -a "$USER" input
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules


# for SKK
(
    cd /usr/share/skk
    for f in SKK-JISYO.*; do
        echo "converting $f"
        sudo iconv -f EUC-JP -t UTF-8 -o "$f.utf8" "$f" || sudo rm "$f.utf8"
    done
    sudo cp ~/compile/skk-emoji-jisyo/SKK-JISYO.emoji.utf8 /usr/share/skk/
    sudo cp ~/compile/SKK-JISYO.emoji-ja/SKK-JISYO.emoji-ja.utf8 /usr/share/skk/
    sudo sed -i 's/euc-jis-2004/utf-8/' /usr/share/skktools/filters/*.rb

    echo ';;; -*- coding: utf-8 -*-' | sudo tee SKK-JISYO.all.utf8 > /dev/null
    skkdic-expr2 SKK-JISYO.L.utf8 *.utf8 utf8/* | \
        ruby -I /usr/share/skktools/filters /usr/share/skktools/filters/annotation-filter.rb | \
        skkdic-expr2 | \
        sudo tee -a SKK-JISYO.all.utf8 > /dev/null
    sudo ln -sf /usr/share/skk/SKK-JISYO.all.utf8 /etc/alternatives/SKK-JISYO
)
