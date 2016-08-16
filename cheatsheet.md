# Regular Installation
## Flash Installation Medium
1. Identify USB Stick with `lsblk`
2. Download Arch Image
3. Verify Checksum
  * `gpg --keyserver-options auto-key-retrieve --verify archlinux-<version>-dual.iso.sig`
4. Flash image onto USB Stick
  * `dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync`

## Installation
1. Boot Image
2. When using UEFI Motherboard check if booted in UEFI Mode
  * `ls /sys/firmware/efi/efivars`
3. Set keyboard layout
  * `ls /usr/share/kbd/keymaps/**/*.map.gz`
  * `Set the keyboard layout`
4. Set console font if certain chars not displayed correctly
  * `setfont lat9w-16`

# RaspberryPi
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
  * `md5sum -c ArchLinuxARM-rpi-latest.tar.gz.md5`
  * `bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root`
  * `sync`
  * `mv root/boot/* boot`
  * `umount boot root`

## Troubleshooting
If SD-Card cannot be accessed by fdisk due to input/output error, try overwriting the whole thing with zeros:
`dd if=/dev/zero of=/dev/mmcblk0 bs=512 count=1`
