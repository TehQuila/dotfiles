#!/usr/bin/bash

WORKDIR=$(pwd)
DIR="${WORKDIR}/config_management"

echo "installing pacman.conf..."
sudo cp $DIR/etc/pacman.conf /etc

echo "installing X11 keyboard/mouse..."
sudo cp $DIR/etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d
sudo cp $DIR/etc/X11/xorg.conf.d/01-mouse.conf /etc/X11/xorg.conf.d

read -n1 -p "Include trackpoint/touchpad configs? [y/n] " laptop
if [[ "$laptop" == "y" ]]; then
   sudo cp $DIR/etc/X11/xorg.conf.d/10-trackpoint.conf /etc/X11/xorg.conf.d
   sudo cp $DIR/etc/X11/xorg.conf.d/11-touchpad.conf /etc/X11/xorg.conf.d
   cp $DIR/home/xbindkeysrc $HOME/.xbindkeysrc
fi

read -n1 -p "Desktop Monitor Setup? [y/n] " desktop
if [[ "$desktop" == "y" ]]; then
   sudo cp $DIR/etc/X11/xorg.conf.d/21-gpu.conf /etc/X11/xorg.conf.d
   sudo cp $DIR/etc/X11/xorg.conf.d/22-monitor.conf /etc/X11/xorg.conf.d
   sudo cp $DIR/etc/X11/xorg.conf.d/23-xscreen.conf /etc/X11/xorg.conf.d
   sudo cp $DIR/etc/X11/xorg.conf.d/99-serverlayout.conf /etc/X11/xorg.conf.d
else
   read -n1 -p "Interactively generate monitor configs? [y/n] " generate
   if [[ "$desktop" == "y" ]]; then
      source config_management/generate_monitor_configs.sh
   fi
fi

echo "installing idea.conf..."
sudo cp $DIR/etc/sysctl.d/idea.conf /etc/sysctl.d

echo "installing base16-shell..."
cp -r $DIR/home/config $HOME/.config
if [[ ! -d "$HOME/.config/base16-shell" ]]; then
   git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
else
   git -C ~/.config/base16-shell pull
fi

cp $DIR/home/bash_profile $HOME/.bash_profile
cp $DIR/home/xinitrc $HOME/.xinitrc
cp $DIR/home/Xresources $HOME/.Xresources
cp $DIR/home/bashrc $HOME/.bashrc

cp $DIR/home/ssh/config $HOME/.ssh/
if [[ ! -d "/etc/openvpn/nordvpn" ]]; then
   sudo mkdir /etc/openvpn/nordvpn
   sudo wget wget https://nordvpn.com/api/files/zip -P /etc/openvpn/nordvpn
   sudo unzip /etc/openvpn/nordvpn/zip
   sudo rm /etc/openvpn/nordvpn/zip
fi

cp -r $DIR/home/i3 $HOME/.i3
cp $DIR/home/gitconfig $HOME/.gitconfig
cp $DIR/home/curlrc $HOME/.curlrc
cp $DIR/home/toprc $HOME/.toprc
cp $DIR/home/vimrc $HOME/.vimrc
[[ -e $HOME/.rvmrc ]] && $DIR/home/rvmrc cp $HOME/.rvmrc

[[ ! -d "$HOME/.mozilla/firefox" ]] && mkdir -p $HOME/.mozilla/firefox
cp -r $DIR/home/mozilla/firefox/* $HOME/.mozilla/firefox
