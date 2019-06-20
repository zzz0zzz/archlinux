#!/bin/sh

# Getting install-aur-package
wget https://github.com/zzz0zzz/archlinux/raw/master/install-aur-package.sh
chmod +x install-aur-package.sh

# Deleting part 2 of install if exists
test -f /install-part2.sh && sudo rm /install-part2.sh

# Some more packages
# texlive-most texlive-langextra
# install-aur-package culmus
sudo pacman -S --noconfirm \
  dash checkbashisms bash-completion  \
  firefox firefox-ublock-origin \
  gnome-keyring git jq unzip \
  rofi alsa-utils python-pipenv emacs gdb \
  xdotool inotify-tools imagemagick ghostscript \
  nginx-mainline php mariadb
gpg --receive-keys FC918B335044912E # for dropbox
./install-aur-package.sh dropbox
./install-aur-package.sh xkblayout-state-git

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
mkdir -p .config/i3blocks
wget https://github.com/zzz0zzz/archlinux/raw/master/config/i3 --output-document .config/i3/config
wget https://github.com/zzz0zzz/archlinux/raw/master/config/i3blocks --output-document .config/i3blocks/config

# emacs
wget https://github.com/zzz0zzz/archlinux/raw/master/config/emacs --output-document .emacs

# mariadb
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mariadb.service
# emulating mysql_secure_installation
mysql --user=root <<_EOF_
  UPDATE mysql.user SET Password=PASSWORD('') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_


# Git configuration
git config --global user.name zzz0zzz
git config --global user.email gurufor@yk20.com
git config --global core.editor emacs
git config --global credential.helper store

# Cleaning
rm after-reboot.sh
rm install-aur-package.sh
