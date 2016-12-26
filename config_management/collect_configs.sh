#!/usr/bin/bash

cp /etc/pacman.conf ./etc
cp /etc/X11/xorg.conf.d/00-keyboard.conf ./etc/X11/xorg.conf.d
cp /etc/X11/xorg.conf.d/01-mouse.conf ./etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/10-trackpoint.conf ]] && cp /etc/X11/xorg.conf.d/10-trackpoint.conf ./etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/11-touchpad.conf ]] && cp /etc/X11/xorg.conf.d/11-touchpad.conf ./etc/X11/xorg.conf.d
[[ -e $HOME/.xbindkeysrc ]] && cp $HOME/.xbindkeysrc ./home/xbindkeysrc
cp $HOME/.bash_profile ./home/bash_profile
cp $HOME/.xinitrc ./home/xinitrc
cp $HOME/.Xresources ./home/Xresources
cp $HOME/.bashrc ./home/bashrc
cp -r $HOME/.i3/* ./home/i3
cp $HOME/.gitconfig ./home/gitconfig
cp $HOME/.curlrc ./home/curlrc
cp $HOME/.toprc ./home/toprc
cp $HOME/.vimrc ./home/vimrc
[[ -e $HOME/.rvmrc ]] && cp $HOME/.rvmrc ./home/rvmrc
cp -r $HOME/.mozilla/* ./home/mozilla
