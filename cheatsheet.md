# Installing Arch Linux
## Preparations
1. Identify USB Stick with `lsblk`
2. Download Arch Image
3. Verify Checksum: `gpg --keyserver-options auto-key-retrieve --verify archlinux-<version>-dual.iso.sig`
4. Flash image onto USB Stick: `dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync`

## Installation
1. Boot Image
2. When using UEFI Motherboard check if booted in UEFI Mode: `ls /sys/firmware/efi/efivars`
3. Set keyboard layout: `loadkeys de_CH-latin1`
4. Set console font if certain chars not displayed correctly: `setfont lat9w-16`
5. Connect to internet
6. Update system clock: `timedatectl set-ntp true`
7. Prepare the storage devices _TODO_
  * Identify the devices with `lsblk`
  * Partition the devices with `fdisk`
  * Format the partitions
    * System partitions: `mkfs.ext4 /dev/sdxy`
    * Swap partitions: `mkswap /dev/sdxy` and `swapon /dev/sdxy`
    * UEFI partitions: `mkfs.fat -F32 /dev/sdxy`
8. Mount Devices
  * Mount root partition: `mount /dev/sdxy /mnt`
  * Mount boot partition: `mkdir -p /mnt/boot` and `mount /dev/sdxy /mnt/boot`
9. Install Base Packages: `pacstrap -i /mnt base base-devel`

## Configure Installation
1. Generate `fstab`: `genfstab -U /mnt >> /mnt/etc/fstab`
2. Chroot into the new system: `arch-chroot /mnt /bin/bash`
3. Set system language
  * Uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen`
  * Execute `locale-gen`
  * Create `/etc/locale.conf` with `LANG=en_US.UTF-8`
4. Persist keyboard layout
  * Create `/etc/vconsole.conf` with `KEYMAP=de_CH-latin1`
5. Time
  * Set timezone: `tzselect` or `timedatectl set-timezone *Zone/SubZone*` (for example Europe/Zurich)
  * Create symlink `/etc/localtime` with `ln -s /usr/share/zoneinfo/Zone/SubZone /etc/localtime`
  * Adjust time skew: `hwclock --systohc --utc`
6. Install Bootloader (GRUB)
  * `pacman -S grub`
  * `grub-install --target=i386-pc /dev/sdx`
  * `grub-mkconfig -o /boot/grub/grub.cfg`
  * When Intel CPU, install `intel-ucode`
7. Network
  * `echo myhostname > /etc/hostname`
  * Append myhostname to `/etc/hosts`
  * Enable Eth: `systemctl enable dhcpcd@enp0s25.service`
  * Install wifi packages: `pacman -S iw wpa_supplicant dialog`
8. Set root password
  * `passwd`

## Finishing up
1. Exit chroot: `exit`
2. Unmount device: `umount -R /mnt`
3. `reboot`

## Personal Configuration
_TODO_
Install and configure sudo

setup latex
install utility packages

Setup DevEnv
Install vim, git, python, venv, ruby, rvn, Phusion Passenger 5, nginx

Setup package management
Configure Pacman, Setup Yaourt

Setup GUI
Setup X11, i3, fehbg, hardware keys

Setup Bash

## RaspberryPi
1. Partition SD-Card
  * `fdisk /dev/mmcblk0`
  * Type o. This will clear out any partitions on the drive.
  * Type p to list partitions. There should be no partitions left.
  * Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
  * Type t, then c to set the first partition to type W95 FAT32 (LBA).
  * Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
  * Write the partition table and exit by typing w.
2. Create the boot partition
  * `mkfs.vfat /dev/mmcblk0p1`
  * `mkdir boot`
  * `mount /dev/mmcblk0p1 boot`
3. Create root filesystem
  * `mkfs.ext4 /dev/mmcblk0p2`
  * `mkdir root`
  * `mount /dev/mmcblk0p2 root`
4. Flash root filesystem and move boot files to the first partition
  * `su`
  * `wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz`
  * `wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz.md5`
  * `md5sum -c ArchLinuxARM-rpi-latest.tar.gz.md5`
  * `bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root`
  * `sync`
  * `mv root/boot/* boot`
  * `umount boot root`
5. Follow the steps 3, 4, 5, 7

## Troubleshooting
If SD-Card cannot be accessed by fdisk due to input/output error, try overwriting the whole thing with zeros:
`dd if=/dev/zero of=/dev/mmcblk0 bs=512 count=1`

# Tips & Tricks
## Share Laptop WLAN through Ethernet
### On Laptop
1. Static IP address
  * Activate Interface: `ip link set up enp0s25`
  * Assign arbitrary address: `ip addr add 192.168.123.100/24 dev enp0s25`
2. Packet forwarding
  * Check current settings: `sysctl -a | grep forward`
  * Activate forwarding if necessary: `sysctl net.ipv4.ip_forward=1`
3. Enable NAT
  * `iptables -t nat -A POSTROUTING -o wlp3s0 -j MASQUERADE`
  * `iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT`
  * `iptables -A FORWARD -i enp0s25 -o wlp3s0 -j ACCEPT`
### On Client
1. Assign arbitrary client addresses
  * `ip addr add 192.168.123.201/24 dev eth0` (first three blocks must match with above)
  * `ip link set up dev eth0`
  * `ip route add default via 192.168.123.100 dev eth0` (address must match laptops enp0s25)
