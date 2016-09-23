# Installing Arch Linux

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
5. Configure Installation

## PC
### Preparations
1. Download Arch Image
2. Verify Checksum: `gpg --keyserver-options auto-key-retrieve --verify archlinux-<version>-dual.iso.sig`
3. Identify USB Stick with `lsblk`
4. Flash image onto USB Stick: `dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync`

### Installation
1. Boot Image
2. When using UEFI Motherboard check if booted in UEFI Mode: `ls /sys/firmware/efi/efivars`
3. Set keyboard layout: `loadkeys de_CH-latin1`
4. Set console font if certain chars not displayed correctly: `setfont lat9w-16`
5. Connect to internet: `ip link set enp0s3 up`
6. Update system clock: `timedatectl set-ntp true`
7. Prepare the storage devices
  * Identify the devices with `lsblk`
  * Partition the devices with `fdisk /dev/sdx`
  * If you install onto an EFI System choose GPT.
    1. Press g for new GPT partition table
    2. Press p to ensure that no partitions are present.
    3. Create boot partition
      * press n, p, ENTER, ENTER, +100M
      * press t, 1 to choose EFI partition type
  * If you install onto an BIOS System choose MBR.
    1. Press o for new MBR partition table.
    2. Press p to ensure that no partitions are present.
    3. Create boot partition
      * press n, p, ENTER, ENTER, +100M
      * leave whatever partition type is chosen
  * Create all other partitions to liking (Swap, home, system)
  * Format partitions:
    1. System partitions: `mkfs.ext4 /dev/sdxy`
    2. Swap partitions: `mkswap /dev/sdxy` and `swapon /dev/sdxy`
    3. UEFI partitions: `mkfs.fat -F32 /dev/sdxy`
8. Mount Devices
  * Mount root partition: `mount /dev/sdxy /mnt`
  * Mount boot partition: `mkdir -p /mnt/boot && mount /dev/sdxy /mnt/boot`
9. Install Base and Base Devel Packages: `pacstrap -i /mnt base base-devel`

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
  * Set timezone: `tzselect` or `timedatectl set-timezone <Zone/SubZone>` (for example Europe/Zurich)
  * Create symlink `/etc/localtime` with `ln -s /usr/share/zoneinfo/<Zone/SubZone> /etc/localtime`
  * Adjust time skew: `hwclock --systohc --utc`
6. Install Bootloader (GRUB)
  * `pacman -S grub`
  * `grub-install --target=i386-pc /dev/sdx`
  * If using Intel CPU, install `intel-ucode`
  * `grub-mkconfig -o /boot/grub/grub.cfg`
7. Network
  * `echo <hostname> > /etc/hostname`
  * Append hostname to `/etc/hosts`
  * Enable Eth: `systemctl enable dhcpcd@enp0s25.service`
  * Install wifi if needed: `pacman -S iw wpa_supplicant dialog`
8. Set root password
  * `passwd`

## Finishing up
1. Exit chroot: `exit`
2. Unmount device: `umount -R /mnt`
3. `reboot`

## Post Installation
1. Setup Screens
2. Create Non-Root User: `useradd -m -G wheel -s /bin/bash <username>`
3. Set Password of new user: `passwd <username>`
4. Enable group `wheel` to use `sudo`: `visudo`
5. Relogin as new user.
6. Install git: `sudo pacman -S git`
7. `mkdir $HOME/workspace && git clone https://github.com/TehQuila/dotfiles.git && cd $HOME/workspace/dotfiles && ./setup

# Tips & Tricks
##Get Hardware Information
lscpu - CPU Info
/proc files, hwinfo, lshw - General HW Info
lspci - PCI buses and connected devices info
lsusb - USB buses and connected device info
lsblk - HDD, optical drives info
df - diskspace
fdisk - partition info
mount - mounted filesystems
free - RAM Info

## VIM Controls
Find first right occurance in line: f+<symbol>
Find first left occurance in line: F+<symbol>
Change in between symbol: c+i/c/v+<symbol>

## input/output error on SD-Card
If SD-Card cannot be accessed by fdisk due to input/output error, try overwriting the whole thing with zeros:
`dd if=/dev/zero of=/dev/mmcblk0 bs=512 count=1`

## Setup Rails Project
1. Create Gemset: `rvm gemset create <name>`
2. Use Gemset: `rvm use 2.3.0@uml_backend`
3. Install bundle and rails: `gem install bundle rails --no-ri --no-rdoc

## Bluetooth
1. systemctl start bluetooth.service
2. bluetoothctl
3. Turn the power to the controller on by entering `power on`.
4. Enter `devices` to get the MAC Address of the device with which to pair.
5. Enter device discovery mode with `scan on` command if device is not yet on the list.
6. Turn the agent on with `agent on`.
7. Enter `pair <mac>` to do the pairing (tab completion works).
8. If using a device without a PIN, one may need to manually trust the device before it can reconnect successfully. Enter `trust <mac>` to do so.
9. Finally, use `connect <mac>` to establish a connection.

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
