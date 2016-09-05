#!/usr/bin/bash

cp /etc/pacman.conf ./etc

cp $HOME/.gitconfig ./home/gitconfig
cp $HOME/.curlrc ./home/curlrc

cp $HOME/.xbindkeysrc ./home/xbindkeysrc
cp -r /etc/X11/xorg.conf.d ./etc/X11/xorg.conf.d

cp $HOME/.bash_profile ./home/bash_profile
cp $HOME/.xinitrc ./home/xinitrc
cp $HOME/.Xresources ./home/Xresources
cp $HOME/.bashrc ./home/bashrc
cp $HOME/.vimrc ./home/vimrc
cp $HOME/.bash_login ./home/bash_login
cp $HOME/.bash_logout ./home/bash_logout
cp $HOME/.toprc ./home/toprc

rm -r ./home/config
cp -r $HOME/.config/base16-shell ./home/config/base16-shell

rm -r ./home/i3
cp -r $HOME/.i3 ./home/i3
cp $HOME/.fehbg ./home/fehbg

cp -r $HOME/.vimrc ./home/vimrc
