#!/usr/bin/bash

sudo pacman -S texlive-bin --noconfirm
sudo pacman -S texlive-science --noconfirm
sudo pacman -S texlive-pictures --noconfirm

read -n1 -p "Setup UZH template? [y/n] " uzh
if [[ "$uzh" == "y" ]]; then
   mkdir -p $HOME/texmf/tex/latex/
   wget https://tug.org/fonts/getnonfreefonts/install-getnonfreefonts > /tmp/install-getnonfreefonts
   sudo texlua /tmp/install-getnonfreefonts --sys
   sudo getnonfreefonts arial-urw
   # todo: download uzh template: https://www.cd.uzh.ch/de/vorlagenboerse/downloads.html
   # mv downloads/Vorlagen_UZH_LaTeX_Publikationen/tex ~/texmf/tex/latex/uzh/
   # update text filename database: sudo mktexlsr
fi
