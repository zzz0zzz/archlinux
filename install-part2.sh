#!/bin/sh

boot_partition="$1"

# Localization
sed -i 's/^#en_IL UTF-8/en_IL UTF-8/' /etc/locale.gen
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_IL.utf8' >> /etc/locale.conf

# Timezone
ln -sf /usr/share/zoneinfo/Israel /etc/localtime
hwclock --systohc --utc

# Network configuration
echo 'Desktop' > /etc/hostname
echo >> /etc/hosts
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.1.1 Desktop.localdomain Desktop' >> /etc/hosts
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager

# Accounts
echo 'root:123456' | chpasswd
useradd -m -s /bin/bash amir
echo 'amir:123456' | chpasswd
echo 'amir ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/amir

# Bootloader
pacman -S --noconfirm grub efibootmgr intel-ucode
mkdir /boot/efi
mount /dev/"$boot_partition" /boot/efi
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
mkdir /boot/efi/EFI/BOOT
cp /boot/efi/EFI/GRUB/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.efi
echo 'bcf boot add 1 fs0:\EFI\GRUB\grubx64.efi \"My GRUB Bootloader\"' > /boot/efi/startup.nsh
echo exit >> /boot/efi/startup.nsh

# Pacman configuration
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sed -i '/^\[multilib\]/{n;s/^#//}' /etc/pacman.conf

echo >> /etc/pacman.conf
echo '[archlinuxfr]' >> /etc/pacman.conf
echo 'SigLevel = Never' >> /etc/pacman.conf
echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf

# Updating
pacman -Syu --noconfirm

# Automatic login drop-in file
mkdir /etc/systemd/system/getty@tty1.service.d
echo '[Service]' >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo 'ExecStart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo 'ExecStart=-/usr/bin/agetty --autologin amir --noclear %I $TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf
systemctl daemon-reload

# Preparing the finish-installation service
curl -s https://raw.githubusercontent.com/zzz0zzz/archlinux/master/after-reboot.sh | sudo tee /usr/local/sbin/finish-installation.sh > /dev/null
# chmod to exec
curl -s https://raw.githubusercontent.com/zzz0zzz/archlinux/master/finish-installation.service | sudo tee /etc/systemd/system/finish-installation.service > /dev/null
systemctl daemon-reload

umount -R /mnt
reboot
