#!/usr/bin/bash

# TODO
# i3 open standard windows on every screen

echo "Initializing pacman..."
sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm --needed

echo "Installing aurman..."
git clone https://aur.archlinux.org/aurman.git /tmp/aurman
(cd /tmp/aurman && exec makepkg -si)

# Install packages
sudo pacman -S bash-completion --noconfirm
sudo pacman -S ntfs-3g --noconfirm
sudo pacman -S i3-wm --noconfirm
sudo pacman -S ttf-inconsolata --noconfirm
sudo pacman -S pepper-flash --noconfirm
sudo pacman -S wget xterm i3lock i3status dmenu feh firefox openssh unzip unrar keepass scrot udisks2 udevil openvpn --noconfirm
aurman -S redshift-minimal --noconfirm

echo "Setting up X11..."
source setup_scripts/setup_x11.sh
echo "Setting up VIM..."
source setup_scripts/setup_vim.sh

read -n1 -p "Setup NAS Share? [y/n] " nas
if [[ "$nas" == "y" ]]; then
   source setup_scripts/setup_nas.sh
fi

read -n1 -p "Setup Sound? [y/n] " sound
if [[ "$sound" == "y" ]]; then
   source setup_scripts/setup_sound.sh
fi

read -n1 -p "Setup Printer? [y/n] " printer
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

echo "running install_configs.sh..."
source config_management/install_configs.sh
