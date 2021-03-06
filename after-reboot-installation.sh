#!/bin/sh

# Some more packages
# texlive-most texlive-langextra
# install-aur-package culmus
sudo pacman -S --noconfirm \
  firefox firefox-ublock-origin \
  gnome-keyring git wget jq unzip \
  dash checkbashisms bash-completion \
  rofi alsa-utils python-pipenv gdb \
  xdotool inotify-tools imagemagick ghostscript

# Downloading all repositories
mkdir Github
cd Github
wget -q -O - https://api.github.com/users/zzz0zzz/repos \
  | jq '.[] | { (.name): .html_url } | .[]' \
  | xargs -n 1 git clone
cd ..

# Getting install-aur-package
wget https://github.com/zzz0zzz/archlinux/raw/master/install-aur-package.sh
chmod +x install-aur-package.sh

# Deleting part 2 of install if exists
test -f /install-part2.sh && sudo rm /install-part2.sh

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

# Emacs.
sudo pacman -S emacs --noconfirm
# Get config file.
wget https://github.com/zzz0zzz/archlinux/raw/master/config/emacs --output-document .emacs

# Git configuration
git config --global user.name zzz0zzz
git config --global user.email gurufor@yk20.com
git config --global core.editor emacs
git config --global credential.helper store

# Cleaning
rm after-reboot-installation.sh
rm install-aur-package.sh




#######################
exit  # END OF SCRIPT 
#######################




# Php.
sudo pacman -S php --noconfirm
# Set timezone.
sed "s/;date.timezone.*/date.timezone = Asia\/Jerusalem/" /etc/php/php.ini

# Apache.
sudo pacman -S apache --noconfirm
# Uncommenting 
sudo sed -e '/.*unique_id_module.*/s/^#//' -i /etc/httpd/conf/httpd.conf
# Php extension.
sudo pacman -S php-apache --noconfirm
#   Replacing mod_mpm_event by mod_mpm_prefork. Commenting mod_mpm_event and uncommenting mod_mpm_prefork.
sudo sed -e '/.*mod_mpm_event.*/s/^/#/' -i /etc/httpd/conf/httpd.conf
sudo sed -e '/.*mod_mpm_prefork.*/s/^#//' -i /etc/httpd/conf/httpd.conf
#   Enabling php. Placing 'LoadModule php7_module modules\/libphp7.so' and 'AddHandler php7-script .php' at the end of the LoadModule list.
sudo sed -i "$(sed -n '/LoadModule/ =' /etc/httpd/conf/httpd.conf | tail -n 1)"'a LoadModule php7_module modules\/libphp7.so\nAddHandler php7-script .php' /etc/httpd/conf/httpd.conf
#   Placing 'Include conf/extra/php7_module.conf' at the end of the Include list (just before 'Configure mod_proxy_html').
sudo sed -i '/^# Configure mod_proxy_html.*/i # Php extension\nInclude conf\/extra\/php7_module.conf\n' /etc/httpd/conf/httpd.conf
# Enabling apache service
sudo systemctl enable httpd.service
# Uncomenting ;extension=mysqli.so in php configuration
sudo sed -i 's/;extension=mysqli/extension=mysqli/' /etc/php/php.ini

# mariadb
sudo pacman -S mariadb --noconfirm
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
# emulating mysql_secure_installation
mysql --user=root <<_EOF_
  CREATE USER 'amir'@'localhost' IDENTIFIED BY '';
  UPDATE mysql.user SET Password=PASSWORD('') WHERE User='root';
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
sudo systemctl stop mariadb.service

# Wordpress
# Downloading
sudo wget https://wordpress.org/latest.tar.gz --directory-prefix=/srv/httpd
sudo tar xvzf /srv/httpd/latest.tar.gz --directory=/srv/httpd
sudo rm /srv/httpd/latest.tar.gz
# Changing wordpress directory ownership
chown -R root:http /srv/http/wordpress
# Creating a configuration file
sudo cp /srv/httpd/wordpress/wp-config-sample.php /srv/httpd/wordpress/wp-config.php
sudo sed -i 's/database_name_here/wordpress/' /srv/http/wordpress/wp-config.php
sudo sed -i 's/username_here/amir/' /srv/http/wordpress/wp-config.php
sudo sed -i 's/password_here//' /srv/http/wordpress/wp-config.php
# Configure mariadb
sudo systemctl start mariadb.service
mysql --user=root <<_EOF_
  CREATE DATABASE wordpress;
  GRANT ALL PRIVILEGES ON wordpress.* TO 'amir'@'localhost' IDENTIFIED BY '';
  FLUSH PRIVILEGES;
_EOF_  
sudo systemctl stop mariadb.service
