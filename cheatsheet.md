physical installation

prepare installation medium
- download arch linux image
- calculate checksum:
--> md5sum -c ArchLinuxARM-rpi-latest.tar.gz.md5
- flash image onto an usb stick
--> find stick: lsblk, make sure its unmounted
--> dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync


using UEFI Motherboard? this cannot be empty: /sys/firmware/efi/efivars

Set the keyboard layout
- see choices
--> ls /usr/share/kbd/keymaps/**/*.map.gz
--> loadkeys de-latin1

If certain characters appear as white squares or other symbols, change the console font
--> setfont lat9w-16




raspberry pi

partition SD-Card

fdisk /dev/mmcblk0
Type o. This will clear out any partitions on the drive.
Type p to list partitions. There should be no partitions left.
Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
Type t, then c to set the first partition to type W95 FAT32 (LBA).
Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
Write the partition table and exit by typing w.

if sdcar cannot be accessed by fdisk (input/output error)
dd if=/dev/zero of=/dev/mmcblk0 bs=512 count=1

create boot partition
mkfs.vfat /dev/mmcblk0p1
mkdir boot
mount /dev/mmcblk0p1 boot

create root filesystem
mkfs.ext4 /dev/mmcblk0p2
mkdir root
mount /dev/mmcblk0p2 root

flash root filesystem and Move boot files to the first partition
su
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
md5sum -c ArchLinuxARM-rpi-latest.tar.gz.md5
bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
sync
mv root/boot/* boot
umount boot root
