#!/usr/bin/bash

echo "User Name: "
read USER_NAME

echo "Setting up laptop? (y/n)"
read LAPTOP_SETUP

cp ./home/gitconfig /home/$USER_NAME/.gitconfig

cp -r ./home/config /home/$USER_NAME/.config
cp -r ./home/i3 /home/$USER_NAME/.i3
cp -r ./home/irssi /home/$USER_NAME/.irssi
cp -r ./home/vim /home/$USER_NAME/.vim

if [[ $LAPTOP_SETUP == "y" ]]; then
   cp ./home/xbindkeysrc.scm /home/$USER_NAME/.xbindkeysrc.scm
   cp ./home/Xmodmap /home/$USER_NAME/.Xmodmap
   cp -r ./etc/X11/xorg.conf.d /etc/X11/xorg.conf.d
else
   cp ./etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/10-evdev.conf
fi

#
# Setup GUI
#
# with pacman -S $(file) can all the files be installed
# setup X11
pacman -S  xorg-xinit xorg-server xorg-xrandr i3 dmenu feh alsa-utils ttf-dejavu

#
# Setup Bash
#
xterm xorg-xrdb xinit bash-completion
cp ./home/bash_profile /home/$USER_NAME/.bash_profile
cp ./home/xinitrc /home/$USER_NAME/.xinitrc
cp ./home/Xresources /home/$USER_NAME/.Xresources
cp ./home/bashrc /home/$USER_NAME/.bashrc
load xrdb ~/.Xressources

#
# yaourt setup
#
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
git clone https://aur.archlinux.org/yaourt.git
(cd /tmp/package-query && exec makepkg -si)
(cd /tmp/yaourt && exec makepkg -si)


#
# Needed for installation
#
pacman -S git curl


#
# MISC
#
pacman -S unzip unrar keepass chromium vlc scrot sudo

#
# utils
#
pacman -S ntfs-3g udisks2 udevil sudo openssh

# setup xbindkeys (for laptop hardware buttons)


#
# VIM setup
#
pacman -S vim

mkdir -p ~/.vim/autoload ~/.vim/bundle

curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

git clone git://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes ~/.vim/bundle/vim-airline-themes
git clone https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim

git clone https://github.com/chriskempson/base16-vim.git /tmp/base16
mv /tmp/base16/colors ~/.vim

vim -u NONE -c "helptags vim-fugitive/doc" -c "helptags vim-airline/doc" -c "helptags vim-airline-themes/doc" -c "helptags ctrlp.vim/doc" -c q

cp ./home/vimrc /home/$USER_NAME/.vimrc
