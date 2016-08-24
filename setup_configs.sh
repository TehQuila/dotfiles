#!/usr/bin/bash

# with pacman -S $(file) can all the files be installed
# execute root stuff: su -c "echo hello"

echo "Setting up laptop? [y/n]"
read LAPTOP

echo "X11 Setup..."
su -c "pacman -S xorg-xinit xorg-server xorg-xrandr xorg-xmodmap xbindkeys"
xmodmap -pke > ~/.Xmodmap # generate keycodes
cp ./home/xbindkeysrc $HOME/.xbindkeysrc.scm # bind keycodes

if [[ "$LAPTOP" == "y" ]]; then
   cp -r ./etc/X11/xorg.conf.d /etc/X11/xorg.conf.d # setup evdev, trackball, trackpad
fi

# TODO query available monitors and generate xorg.conf
echo "...done!"

echo "Bash Setup..."
su -c "pacman -S xterm xorg-xrdb xinit bash-completion"
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources
cp ./home/bashrc $HOME/.bashrc
load xrdb ~/.Xressources


mkdir -r $HOME/.config
cp -r ./home/config/base16-shell $HOME/.config
echo "...done!"

echo "GUI Setup..."
su -c "pacman -S i3 dmenu feh alsa-utils ttf-dejavu"
cp -r ./home/i3 $HOME/.i3
cp -r ./home/fehbg $HOME/.fehbg




cp ./home/gitconfig $HOME/.gitconfig




#
# Setup Bash
#
echo "Setup Yaourt..."
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/package-query && exec makepkg -si)
(cd /tmp/yaourt && exec makepkg -si)
echo "...done!"

# Install AUR packages
yaourt -S folingathome


#
# Needed for installation
#
pacman -S git curl


#
# MISC
#
pacman -S unzip unrar keepass chromium vlc scrot ntfs-3g udisks2 udevil xclip




#
# VIM setup
#
pacman -S vim

cp -r ./home/vim /home/$USER_NAME/.vim

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
