#!/bin/sh

# Deleting part 2 of install if exists
test -f /install-part2.sh && sudo rm /install-part2.sh

# Some more packages
# texlive-most texlive-langextra noto-fonts
sudo pacman -S --noconfirm unzip dash checkbashisms bash-completion  \
                           firefox-ublock-origin gnome-keyring git jq \
                           rofi alsa-utils python-pipenv emacs gdb

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

## David libre font (Assuming there is no /etc/X11/xorg.conf)
#wget https://github.com/meirsadan/david-libre/releases/download/v1.001/DavidLibre_TTF_v1.001.zip
#cd /usr/share/fonts
#sudo mkdir david-libre
#cd david-libre
#sudo mv ~/DavidLibre_TTF_v1.001.zip .
#sudo unzip DavidLibre_TTF_v1.001.zip
#sudo rm DavidLibre_TTF_v1.001.zip OFL.txt
#echo 'Section "Files"' | sudo tee /etc/X11/xorg.conf
#echo '  FontPath "/usr/share/fonts/david-libre"' | sudo tee -a /etc/X11/xorg.conf
#echo 'EndSection' | sudo tee -a /etc/X11/xorg.conf
#cd ~

# AUR packages
# culmus
#git clone https://aur.archlinux.org/culmus.git
#cd culmus
#makepkg -sirc --noconfirm
#cd ..
#sudo rm -r culmus

# Git configuration
git config --global user.name zzz0zzz
git config --global user.email gurufor@yk20.com
git config --global core.editor emacs
git config --global credential.helper store
