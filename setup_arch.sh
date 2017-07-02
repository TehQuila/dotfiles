#!/usr/bin/bash

# TODO
# i3 open standard windows on every screen
# add Fn keys to xbindkeysrc
# add prt scrn key to xbindkey --> use scrot
# bluetooth: https://bbs.archlinux.org/viewtopic.php?id=166678&p=2
# printer
# latex

# Initialize pacman
sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm --needed

# Install yaourt
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
(cd /tmp/package-query && exec makepkg -si)
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/yaourt && exec makepkg -si)

# Install packages
sudo pacman -S bash-completion --noconfirm
sudo pacman -S ntfs-3g --noconfirm
sudo pacman -S alsa-utils --noconfirm
sudo pacman -S i3-wm --noconfirm
sudo pacman -S ttf-inconsolata --noconfirm
sudo pacman -S wget xterm i3lock i3status dmenu feh firefox openssh unzip unrar keepass scrot udisks2 udevil openvpn --noconfirm
yaourt -S pepper-flash --noconfirm
yaourt -S xflux --noconfirm

timedatectl set-ntp true

source setup_scripts/setup_x11.sh
source setup_scripts/setup_vim.sh

read -n1 -p "Setup NAS Share? [y/n] " nas
if [[ "$nas" == "y" ]]; then
   source setup_scripts/setup_nas.sh
fi

read -n1 -p "Setup Bluetooth? [y/n] " bluetooth
if [[ "$bluetooth" == "y" ]]; then
   source setup_scripts/setup_bluetooth.sh
fi

read -n1 -p "Setup printer? [y/n] " printer
if [[ "$printer" == "y" ]]; then
   source setup_scripts/setup_printer.sh
fi

read -n1 -p "Setup LaTeX? [y/n] " latex
if [[ "$latex" -eq "y" ]]; then
   source setup_scripts/setup_latex.sh
fi

read -n1 -p "Setup Folding At Home? [y/n] " fah
if [[ "$fah" == "y" ]]; then
   source setup_scripts/setup_fah.sh
fi

source config_management/install_configs.sh
