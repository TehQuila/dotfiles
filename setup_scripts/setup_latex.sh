#!/usr/bin/bash

sudo pacman -S texlive-bin --noconfirm
sudo pacman -S texlive-science --noconfirm
sudo pacman -S texlive-pictures --noconfirm

read -n1 -p "Setup UZH template? [y/n] " uzh
if [[ "$uzh" == "y" ]]; then
   mkdir -p $HOME/texmf/tex/latex/
   wget https://tug.org/fonts/getnonfreefonts/install-getnonfreefonts > /tmp/install-getnonfreefonts
   texlua /tmp/install-getnonfreefonts
   sudo getnonfreefonts arial-urw
fi
