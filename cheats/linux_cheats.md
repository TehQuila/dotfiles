# Handy Commands
Rerun the last command as sudo: `sudo !!`

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
5. Connect to internet: `ip link set enp0s25 up`
TODO: Wifi during installation?
6. Update system clock: `timedatectl set-ntp true`
7. Prepare the storage devices
  * Identify the devices with `lsblk`
  * Partition the devices with `fdisk /dev/sdx`
  * If you install onto an EFI System choose GPT.
    1. Press g for new GPT partition table
    2. Press p to ensure that no partitions are present.
    3. Create boot partition
      * press n, ENTER, ENTER, +100M
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
   * If using Intel CPU, install `intel-ucode`
   * Dual Boot Where Windows is installed for UEFI with the following partitions:
      * a partition of type ef00 EFI System and filesystem FAT32,
      * a partition of type 0c01 Microsoft reserved, generally of size 128 MiB,
      * a partition of type 0700 Microsoft basic data and of filesystem NTFS, which corresponds to C:\,
      * potentially system recovery and backup partitions and/or secondary data partitions (corresponding often to D:\ and above).
      * Mind that there is no need to create an additional EFI System Partition (ESP), since it already exists
      1. Edit `/etc/grub.d/40_custom` and paste in
      ```
      if [ "${grub_platform}" == "efi" ]; then
         menuentry "Microsoft Windows Vista/7/8/8.1 UEFI-GPT" {
            insmod part_gpt
            insmod fat
            insmod search_fs_uuid
            insmod chain
            search --fs-uuid --set=root <hints_string> <fs_uuid>
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
         }
      fi
      ```
      2. Where <hints_string> is the output of: `grub-probe --target=hints_string $esp/EFI/Microsoft/Boot/bootmgfw.efi`
      3. And <fs_uuid> is the output of: `grub-probe --target=fs_uuid $esp/EFI/Microsoft/Boot/bootmgfw.efi`
   * When installing to GPT/UEFI
      * `pacman -S grub efibootmgr`
      * `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub`
   * When installing to MBR/BIOS
      * `pacman -S grub`
      * `grub-install --target=i386-pc /dev/sdx`
   * Generate grub config (which is collection configs from /etc/grub.d: `grub-mkconfig -o /boot/grub/grub.cfg`
7. Configure Network
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
1. Create non-root user: `useradd -m -G wheel -s /bin/bash <username>`
2. Set password of new user: `passwd <username>`
3. Enable group `wheel` to use `sudo`: `visudo`
4. Relogin as new user.
5. Install git: `sudo pacman -S git`
6. Initialize workspace:
   * `mkdir $HOME/workspace`
   * `git clone https://github.com/TehQuila/dotfiles.git $HOME/workspace/dotfiles`
8. Setup base system: `./$HOME/workspace/dotfiles/setup_base.sh`
9. Relogin
10. Activate base16 shell: `base16_default-dark`
11. When setting up WLAN: `wifi-menu`
12. Setup workspace: `./$HOME/workspace/dotfiles/setup_workspace.sh`

# Server Hardening
## Three principles
1. Minimal Attack Surface: Disable everything you don't need.
2. Secure everything that must be exposed
3. Assume that every measure will be defeated

## Minimize Attack surface
- Display all running processes (without kernel): ps -ef | grep -v \] | wc -l
- Display all open Ports: lsof -ni | grep LISTEN
- Disable everything you don't need

## Setup Firewall with iptables
make sure forwarding is off and clear everything
also turn off ipv6 cause if you don't need it turn it off
`sysctl net.ipv6.conf.all.disable_ipv6=1`
`sysctl net.ipv4.ip_forward=0`
`iptables -F`
`iptables --flush`
`iptables -t nat --flush`
`iptables -t mangle --flush`
`iptables --delete-chain`
`iptables -t nat --delete-chain`
`iptables -t mangle --delete-chain`

make the default -drop everything
`iptables --policy INPUT DROP`
`iptables --policy OUTPUT ACCEPT`
`iptables --policy FORWARD DROP`

allow all in loopback
`iptables -A INPUT -i lo -j ACCEPT`

allow related
`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

allow ssh
`iptables -A INPUT -m tcp -p tcp --dport 22 -j ACCEPT`

## Setup Scheduled Updates
With cronjob or smth.

## Disable remote root login
In `/etc/ssh/sshd_config`
set `PermitRootLogin no`

## Disable over all root login (root only accessible via sudo)
`sudo passwd -l root`

## Only grant remote access to users which need it
In `/etc/ssh/sshd_config`
set `AllowUsers` or `AllowGroups`

## Enable passkey
generate passkey
`ssh-keygen -t rsa`
and store public bit in `~/.ssh/authorized_keys` on the server

## disable password authentication
In `/etc/ssh/sshd_config`
Set `PasswordAuthentication no`

## Only enable secure encryption
In `/etc/ssh/sshd_config`
Set `Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128`
And `MACs hmac-sha1,umac-64@openssh.com,hmac-ripemd160`

## Disable SElinux
In `/etc/selinux/config`
comment out `#SELINUX=enforcing`
turn it of `fSELINUX=disabled`
restart the system

## Enable automated blocklist
```shell
#!/bin/bash

PATH=$PATH:/sbin
WD=`pwd`
TMP_DIR=$WD/tmp
IP_TMP=$TMP_DIR/ip.temp
IP_BLOCKLIST=$WD/ip-blocklist.conf
IP_BLOCKLIST_TMP=$TMP_DIR/ip-blocklist.temp
list="chinese nigerian russian lacnic exploited-servers"
BLOCKLISTS=(
"http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" # Project Honey Pot Directory of Dictionary Attacker IPs
"http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1" # TOR Exit Nodes
"http://www.maxmind.com/en/anonymous_proxies" # MaxMind GeoIP Anonymous Proxies
"http://danger.rulez.sk/projects/bruteforceblocker/blist.php" # BruteForceBlocker IP List
"http://rules.emergingthreats.net/blockrules/rbn-ips.txt" # Emerging Threats - Russian Business Networks List
"http://www.spamhaus.org/drop/drop.lasso" # Spamhaus Dont Route Or Peer List (DROP)
"http://cinsscore.com/list/ci-badguys.txt" # C.I. Army Malicious IP List
"http://www.openbl.org/lists/base.txt"  # OpenBLOCK.org 30 day List
"http://www.autoshun.org/files/shunlist.csv" # Autoshun Shun List
"http://lists.blocklist.de/lists/all.txt" # blocklist.de attackers
)

mkdir $TMP_DIR
cd  $TMP_DIR
# This gets the various lists
for i in "${BLOCKLISTS[@]}"; do
   curl "$i" > $IP_TMP
   grep -Po '(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?' $IP_TMP >> $IP_BLOCKLIST_TMP
done

for i in `echo $list`; do
   wget --quiet http://www.wizcrafts.net/$i-iptables-blocklist.html # This section gets wizcrafts lists
   cat $i-iptables-blocklist.html | grep -v \< | grep -v \: | grep -v \; | grep -v \# | grep [0-9] > $i.txt # Grep out all but ip blocks
   cat $i.txt >> $IP_BLOCKLIST_TMP # Consolidate blocks into master list
done

sort $IP_BLOCKLIST_TMP -n | uniq > $IP_BLOCKLIST
rm $IP_BLOCKLIST_TMP
wc -l $IP_BLOCKLIST

ipset flush blocklist
egrep -v "^#|^$" $IP_BLOCKLIST | while IFS= read -r ip; do
   ipset add blocklist $ip
done

#cleanup
rm -fR $TMP_DIR/*

exit 0
```

# Tips & Tricks
## CUPS
lpr <file> print a file
lpq check the queue
lprm remove last entry only
lprm remove all entries

### Remove a Printer
cupsreject queue_name
cupsdisable queue_nameA
lpadmin -x queue_name

## Get Hardware Information
lscpu - CPU Info
/proc files, hwinfo, lshw - General HW Info
lspci - PCI buses and connected devices info
lsusb - USB buses and connected device info
lsblk - HDD, optical drives info
df - diskspace
fdisk - partition info
mount - mounted filesystems
free - RAM Info
lsmod - Display loaded kernel modules (includes device drivers)

## input/output error on SD-Card
If SD-Card cannot be accessed by fdisk due to input/output error, try overwriting the whole thing with zeros:
`dd if=/dev/zero of=/dev/mmcblk0 bs=512 count=1`

## Setup Rails Project
1. Create Gemset: `rvm gemset create <name>`
2. Use Gemset: `rvm use 2.3.0@uml_backend`
3. Install bundle and rails: `gem install bundle rails --no-ri --no-rdoc

## TODO Bluetooth
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
