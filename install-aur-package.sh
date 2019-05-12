
git clone https://aur.archlinux.org/$1.git
cd $1
makepkg -sirc --noconfirm
cd ..
sudo rm -r $1
