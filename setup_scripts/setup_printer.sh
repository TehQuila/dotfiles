#!/usr/bin/bash

sudo pacman -S cups --noconfirm
sudo pacman -S hplips --noconfirm

systemctl enable org.cups.cupsd.service
systemctl start org.cups.cupsd.service

sudo hp-setup -i
