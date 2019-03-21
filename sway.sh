#!/bin/sh

sudo pacman -S --noconfirm weston git

git clone https://aur.archlinux.org/wlroots-git.git
cd wlroots-git
makepkg --noconfirm -si

git clone https://aur.archlinux.org/sway-git.git
cd sway-git
makepkg --noconfirm -si

sudo pacman -S --noconfirm gtk3 i3status

mkdir -p /home/amir/.config/sway/
cp /etc/sway/config /home/amir/.config/sway/
echo >> /home/amir/.config/sway/config
echo 'bar {' >> /home/amir/.config/sway/config
echo '  status_command i3status' >> /home/amir/.config/sway/config
echo '}' >> /home/amir/.config/sway/config

echo >> /home/amir/.bash_profile
echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then' >> /home/amir/.bash_profile
echo '  export XKB_DEFAULT_LAYOUT=us,il' >> /home/amir/.bash_profile
echo '  export XKB_DEFAULT_MODEL=pc101' >> /home/amir/.bash_profile
echo '  export XKB_DEFAULT_OPTIONS=grp:lctrl_lshift_toggle' >> /home/amir/.bash_profile
echo '  exec sway' >> /home/amir/.bash_profile
echo 'fi' >> /home/amir/.bash_profile


#cp ???????? /home/amir/.config/i3status/config
#echo >> /home/amir/.config/i3status/config
#echo 'general {' >> /home/amir/.config/i3status/config
#echo '  colors = true' >> /home/amir/.config/i3status/config
#echo '  interval = 5' >> /home/amir/.config/i3status/config
#echo } >> /home/amir/.config/i3status/config
