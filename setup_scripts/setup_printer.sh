#!/usr/bin/bash

sudo pacman -S cups avahi nss-mdns --noconfirm
systemctl enable avahi-daemon
systemctl enable org.cups.cupsd
systemctl start avahi-daemon
systemctl start org.cups.cupsd

echo "Enter Printer name: "
read queue_name

sudo lpinfo -v
echo "Paste Printer URI: "
read uri

sudo lpinfo -m
echo "Paste Printer Model: "
read model

sudo lpadmin -p "$queue_name" -E -v "$uri" -m "$model"
sudo lpoptions -d $queue_name
sudo cupsenable $queue_name
sudo cupsaccept $queue_name
