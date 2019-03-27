#!/bin/sh

# Deleting part 2 of install if exists
test -f /install-part2.sh && sudo rm /install-part2.sh

# Some more packages
sudo pacman -S --noconfirm unzip dash checkbashisms bash-completion ttf-dejavu \
                           firefox epiphany gnome-keyring emacs gdb git jq rofi \
                           texlive-most texlive-langextra

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
sudo pacman -S --noconfirm i3-gaps rxvt-unicode feh i3status
mkdir -p .config/i3
wget https://github.com/zzz0zzz/archlinux/raw/master/config/i3 --output-document .config/i3/config

# AUR packages
# culmus
git clone https://aur.archlinux.org/culmus.git
cd culmus
makepkg -sirc
cd ..
rm -r culmus

# Git configuration
git config --global user.name zzz0zzz
git config --global user.email gurufor@yk20.com
git config --global core.editor emacs
git config --global credential.helper store
