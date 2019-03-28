#!/bin/sh

device_name="$1"

if test "$device_name" = 'nvme0n1'; then
  partition_prefix="$device_name"p
else
  partition_prefix="$device_name"
fi

# Wiping the hard drive
sgdisk -Z /dev/"$device_name"

# Partitioning
sgdisk /dev/"$device_name" --new=1:0:+1G  --typecode=1:ef00 --change-name=1:boot
sgdisk /dev/"$device_name" --new=2:0:+10G --typecode=2:8200 --change-name=2:swap
sgdisk /dev/"$device_name" --new=3:0:+20G --typecode=3:8304 --change-name=3:root
sgdisk /dev/"$device_name" --new=4:0:0    --typecode=4:8302 --change-name=4:home

# Formatting
mkfs.fat -F32 /dev/"$partition_prefix"1
mkswap /dev/"$partition_prefix"2; swapon /dev/"$partition_prefix"2
mkfs.ext4 /dev/"$partition_prefix"3
mkfs.ext4 /dev/"$partition_prefix"4

# Mounting
mount /dev/"$partition_prefix"3 /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount /dev/"$partition_prefix"1 /mnt/boot
mount /dev/"$partition_prefix"4 /mnt/home

# Synchronizing databases
pacman -Sy

# Ranking best mirror
pacman -S --noconfirm pacman-contrib
curl -s "https://www.archlinux.org/mirrorlist/?country=IL&country=GR&protocol=https&use_mirror_status=on" \
  | sed -e 's/^#Server/Server/' -e '/^#/d' \
  | rankmirrors -n 3 - \
  > /etc/pacman.d/mirrorlist

# Installing the base packages
pacstrap /mnt base base-devel

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Preparing second part of install
wget https://github.com/zzz0zzz/archlinux/raw/master/install-part2.sh
chmod +x install-part2.sh
mv install-part2.sh /mnt

# Changing root into the new system
arch-chroot /mnt ./install-part2.sh "$partition_prefix"1
