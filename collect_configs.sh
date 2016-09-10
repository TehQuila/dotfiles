#!/usr/bin/bash

cp /etc/pacman.conf ./etc

cp $HOME/.gitconfig ./home/gitconfig
cp $HOME/.curlrc ./home/curlrc

cp $HOME/.xbindkeysrc ./home/xbindkeysrc
cp /etc/X11/xorg.conf.d/* ./etc/X11/xorg.conf.d

cp $HOME/.bash_profile ./home/bash_profile
cp $HOME/.xinitrc ./home/xinitrc
cp $HOME/.Xresources ./home/Xresources
cp $HOME/.bashrc ./home/bashrc
cp $HOME/.toprc ./home/toprc

cp $HOME/.i3/* ./home/i3
cp $HOME/.fehbg ./home/fehbg

cp $HOME/.vimrc ./home/vimrc

cp $HOME/.rvmrc ./home/rvmrc
