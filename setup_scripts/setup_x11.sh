#!/usr/bin/bash

sudo pacman -S xorg-server --noconfirm
sudo pacman -S xorg-xinit --noconfirm
sudo pacman -S xorg-xrandr --noconfirm
sudo pacman -S xorg-xrdb --noconfirm

read -n1 -p "Setup Laptop HW Button configs? [y/n] " laptop
if [[ "$laptop" == "y" ]]; then
   sudo pacman -S xorg-xmodmap --noconfirm
   sudo pacman -S xbindkeys --noconfirm
   xmodmap -pke > $HOME/.Xmodmap # generate keycodes
fi

echo "installing graphics driver"
controller=$(lspci | grep -i vga)
if [[ "$(echo $controller | grep Intel -c)" ]]; then
   sudo pacman -S xf86-video-intel --noconfirm
elif [[ "$(echo $controller | grep ATI -c)" ]]; then
   sudo pacman -S xf86-video-ati --noconfirm
elif [[ "$(echo $controller | grep NVIDIA -c)" ]]; then
   sudo pacman -S nvidia --noconfirm
else
   sudo pacman -S xf86-video-fbdev --noconfirm
fi
