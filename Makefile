files=Xmodmap Xresources stumpwmrc tmux.conf xinitrc zshrc

default: $(files)

$(files):
	if [ ! -h ~/.$@ ]; then ln -s ./$@ ~/.$@; fi
