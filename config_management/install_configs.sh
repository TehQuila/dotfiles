#!/usr/bin/bash

if [[ ! -d $HOME/.config/base16-shell ]]; then
   mkdir $HOME/.config
   git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
   bash -c "base16_default-dark"
fi
sudo cp ./etc/pacman.conf /etc
sudo cp ./etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d
sudo cp ./etc/X11/xorg.conf.d/01-mouse.conf /etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/10-trackpoint.conf ]] && cp /etc/X11/xorg.conf.d/10-trackpoint.conf ./etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/11-touchpad.conf ]] && cp /etc/X11/xorg.conf.d/11-touchpad.conf ./etc/X11/xorg.conf.d
[[ -e $HOME/.xbindkeysrc ]] && cp ./home/xbindkeysrc $HOME/.xbindkeysrc
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources
cp ./home/bashrc $HOME/.bashrc
cp -r ./home/i3/* $HOME/.i3
cp ./home/gitconfig $HOME/.gitconfig
cp ./home/curlrc $HOME/.curlrc
cp ./home/toprc $HOME/.toprc
cp ./home/vimrc $HOME/.vimrc
[[ -e $HOME/.rvmrc ]] && ./home/rvmrc cp $HOME/.rvmrc
cp -r ./home/mozilla/* $HOME/.mozilla
