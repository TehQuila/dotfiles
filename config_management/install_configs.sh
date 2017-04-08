#!/usr/bin/bash

WORKDIR=$(pwd)
DIR="${WORKDIR}/config_management"

if [[ ! -d $HOME/.config/base16-shell ]]; then
   mkdir $HOME/.config
   git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
   bash -c "base16_default-dark"
fi
sudo cp $DIR/etc/pacman.conf /etc
sudo cp $DIR/etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d
sudo cp $DIR/etc/X11/xorg.conf.d/01-mouse.conf /etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/10-trackpoint.conf ]] && cp /etc/X11/xorg.conf.d/10-trackpoint.conf $DIR/etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/11-touchpad.conf ]] && cp /etc/X11/xorg.conf.d/11-touchpad.conf $DIR/etc/X11/xorg.conf.d
[[ -e $HOME/.xbindkeysrc ]] && cp $DIR/home/xbindkeysrc $HOME/.xbindkeysrc
cp $DIR/home/bash_profile $HOME/.bash_profile
cp $DIR/home/xinitrc $HOME/.xinitrc
cp $DIR/home/Xresources $HOME/.Xresources
cp $DIR/home/bashrc $HOME/.bashrc
cp $DIR/home/ssh/config $HOME/.ssh/
cp -r $DIR/home/i3/* $HOME/.i3
cp $DIR/home/gitconfig $HOME/.gitconfig
cp $DIR/home/curlrc $HOME/.curlrc
cp $DIR/home/toprc $HOME/.toprc
cp $DIR/home/vimrc $HOME/.vimrc
[[ -e $HOME/.rvmrc ]] && $DIR/home/rvmrc cp $HOME/.rvmrc
[[ ! -d "$HOME/.mozilla/firefox" ]] && mkdir -p $HOME/.mozilla/firefox
cp -r $DIR/home/mozilla/firefox/* $HOME/.mozilla/firefox
