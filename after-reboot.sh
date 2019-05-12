#!/bin/sh

# Deleting part 2 of install if exists
test -f /install-part2.sh && sudo rm /install-part2.sh

# Some more packages
sudo pacman -S --noconfirm
  dash checkbashisms bash-completion  \
  firefox firefox-ublock-origin \
  gnome-keyring git jq unzip \
  rofi alsa-utils python-pipenv emacs gdb \
  texlive-most texlive-langextra
install-aur-package culmus
install-aur-package xkblayout-state-git

# AUR package - culmus
git clone https://aur.archlinux.org/culmus.git
cd culmus
makepkg -sirc --noconfirm
cd ..
sudo rm -r culmus

# Aur package - xkblayout-state
git clone https://aur.archlinux.org/xkblayout-state-git.git
cd xkblayout-state-git
makepkg -sirc --noconfirm
cd ..
sudo rm -r xkblayout-state-git

# xorg
sudo pacman -S --noconfirm xorg xorg-apps
sudo pacman -S --noconfirm xf86-video-vmware xf86-video-fbdev xf86-video-intel
sudo pacman -S --noconfirm xorg-xinit mesa xterm
echo >> .bash_profile
echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi' >> .bash_profile
wget https://github.com/zzz0zzz/archlinux/raw/master/config/xinitrc -O .xinitrc
curl -s https://api.github.com/repos/zzz0zzz/archlinux/contents/config/Xresources \
  | jq '.[].name' \
  | xargs -n 1 -I % sh -c 'echo \#include \".Xresources.d/%\" >> .Xresources \
                        && wget https://github.com/zzz0zzz/archlinux/raw/master/config/Xresources/% \
                             --directory-prefix=.Xresources.d'

# i3
sudo pacman -S --noconfirm i3-gaps rxvt-unicode feh i3blocks
mkdir -p .config/i3
wget https://github.com/zzz0zzz/archlinux/raw/master/config/i3 --output-document .config/i3/config

# Git configuration
git config --global user.name zzz0zzz
git config --global user.email gurufor@yk20.com
git config --global core.editor emacs
git config --global credential.helper store
