LANG=C xdg-user-dirs-gtk-update
gsettings set org.gnome.desktop.input-sources xkb-options ['ctrl:nocaps']

sudo apt install zsh git curl tmux uim-skk skkdic skkdic-extra python3-pip build-essential cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev autoconf texinfo libgif-dev libtiff-dev libjpeg-dev libpng-dev libxpm-dev libgtk-3-dev libgnutls28-dev libtinfo-dev kakasi libcurl4-openssl-dev

sudo pip3 install xkeysnail wakatime

sudo groupadd -f uinput
sudo useradd -G input,uinput -s /sbin/nologin xkeysnail
sudo tee /etc/udev/rules.d/40-udev-xkeysnail-uinput.rules <<'EOF'
KERNEL=="uinput", GROUP="uinput"
EOF

sudo tee /etc/udev/rules.d/40-udev-xkeysnail-input.rules <<'EOF'
KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"
EOF

sudo tee /etc/modules-load.d/uinput.conf <<'EOF'
uinput
EOF

sudo tee /etc/sudoers.d/10-installer <<EOF
$USER ALL=(ALL) ALL,\
         (xkeysnail) NOPASSWD: /usr/local/bin/xkeysnail
EOF
