sudo pacman -S cups avahi nss-mdns --noconfirm
systemctl enable avahi-daemon.service
systemctl enable org.cups.cupsd.service
systemctl start avahi-daemon.service
systemctl start org.cups.cupsd.service

sudo lpinfo -v
echo "Enter Printer name: "
read queue_name
echo "Paste Printer URI: "
read uri

sudo lpadmin -p $queue_name -E -v "$uri"
sudo lpoptions -d $queue_name
sudo cupsenable $queue_name
sudo cupsaccept $queue_name
