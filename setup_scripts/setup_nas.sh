#!/usr/bin/bash

sudo pacman -S cifs-utils --noconfirm

mkdir $HOME/.credentials
read -p "Enter NAS username: " user
read -p "Enter NAS password: " password
{
   echo "username=${username}" >&3
   echo "password=${password}" >&3
} 3>>$HOME/.credentials/BigData
sudo chmod 600 .credentials

sudo mkdir /mnt/BigData
{
   sudo echo "\# BigData" >&3
   sudo echo "//192.168.0.2/Share      /mnt/BigData    cifs     credentials=$HOME/.credentials/BigData,x-systemd.automount,iocharset=utf8     0 0" >&3
} 3>>/etc/fstab
