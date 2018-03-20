#!/usr/bin/bash

sudo pacman -S cifs-utils --noconfirm

mkdir $HOME/.credentials
read -p "Enter samba username: " username
read -p "Enter samba password: " password
{
   echo "username=${username}" >&3
   echo "password=${password}" >&3
} 3>>$HOME/.credentials/bigdata
sudo chmod 600 .credentials

sudo mkdir /mnt/bigdata
{
   sudo echo "\# bigdata" >&3
   sudo echo "//192.168.178.2/data	/mnt/bigdata	cifs     uid=tim,credentials=/home/tim/.credentials/bigdata,nofail,noauto,x-systemd.automount,x-systemd.requires=network-online.target,x-systemd.device-timeout=10,iocharset=utf8,vers=3.0	0 0" >&3
} 3>>/etc/fstab
