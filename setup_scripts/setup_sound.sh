#!/usr/bin/bash

sudo pacman -S alsa-utils --noconfirm

read -n1 -p "Install pulseaudio? [y/n] " pulse
if [[ "$pulse" == "y" ]]; then
   sudo pacman -S pulseaudio-alsa --noconfirm
   sudo pacman -S pulseaudio --noconfirm
   sudo pacman -S pavucontrol --noconfirm
fi
