#!/usr/bin/bash

cp $HOME/.bash_profile ./home/bash_profile
cp $HOME/.bashrc ./home/bashrc
cp $HOME/.bashrc ./home/bashrc
cp $HOME/.vimrc ./home/vimrc
cp $HOME/.xinitrc ./home/xinitrc
cp $HOME/.Xresources ./home/Xresources
cp $HOME/.toprc ./home/toprc

cp $HOME/.fehbg ./home/fehbg

rm -r ./home/config
cp -r $HOME/.config/base16-shell ./home/config/base16-shell

rm -r ./home/i3
cp -r $HOME/.i3 ./home/i3

rm -r ./home/vim
cp -r $HOME/.vim ./home
mv ./home/.vim ./home/vim

rm -r ./etc/X11
cp -r /etc/X11/xorg.conf.d/ ./etc

# TODO add nginx config
