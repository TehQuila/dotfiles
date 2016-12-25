#!/usr/bin/bash

sudo pacman -S bluez-utils
sudo pacman -S alsa-plugins
sudo pacman -S pulseaudio-alsa
sudo pacman -S bluez dbus pulseaudio
modprobe btusb

sudo systemctl enable dbus
sudo systemctl start dbus
dbus-daemon --session --fork

sudo systemctl start bluetooth
