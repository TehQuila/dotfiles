#!/usr/bin/bash
# TODO setup printing

# TODO think about different optional software
echo "Setting up laptop? [y/n]"
read LAPTOP

echo "Preparing Setup..."
cp ./home/gitconfig $HOME/.gitconfig
cp ./home/curlrc $HOME/.curlrc

sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm --needed
echo "...done!"

# TODO install apropriate video driver
# TODO query available monitors and generate xorg.conf
echo "X11 Setup..."
sudo pacman -S xterm xorg-xrdb xorg-xinit xorg-server xorg-xrandr --noconfirm

cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources

if [[ "$LAPTOP" -eq "y" ]]; then
   sudo pacman -S xorg-xmodmap xbindkeys --noconfirm
   xmodmap -pke > ~/.Xmodmap # generate keycodes
   cp ./home/xbindkeysrc $HOME/.xbindkeysrc # bind keycodes
   sudo cp ./etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d
fi

echo "...done!"

echo "Bash Setup..."
sudo pacman -S bash-completion --noconfirm
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/bashrc $HOME/.bashrc
cp ./home/toprc $HOME/.toprc

if [[ ! -d "$DIRECTORY" ]]; then
   mkdir $HOME/.config
fi

git clone git://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
base16_default_dark
echo "...done!"

echo "GUI Setup..."
sudo pacman -S i3 dmenu feh alsa-utils ttf-dejavu --noconfirm
cp -r ./home/i3 $HOME/.i3
cp -r ./home/fehbg $HOME/.fehbg
echo "...done!"

echo "Installing utilities..."
sudo pacman -S openssh unzip unrar keepass chromium vlc scrot ntfs-3g udisks2 udevil xclip --noconfirm
echo "...done!"

echo "Setting up Bluetooth..."
sudo pacman -S modprobe btusb --noconfirm
modprobe btusb
echo "...done!"

echo "Setup Yaourt..."
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/package-query && exec makepkg -si)
(cd /tmp/yaourt && exec makepkg -si)
echo "...done!"

if [[ "$LAPTOP" -eq "n" ]]; then
   yaourt -S folingathome
fi

echo "VIM Setup..."
sudo pacman -S vim --noconfirm
cp ./home/vimrc $HOME/.vimrc

mkdir -p $HOME/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

mkdir -p $HOME/.vim/bundle
git clone git://github.com/vim-airline/vim-airline $HOME/.vim/bundle/vim-airline
git clone git://github.com/vim-airline/vim-airline-themes $HOME/.vim/bundle/vim-airline-themes
git clone git://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim
vim -u NONE -c "helptags vim-airline/doc" -c "helptags vim-airline-themes/doc" -c "helptags ctrlp.vim/doc" -c q

mkdir -p $HOME/.vim/colors
git clone git://github.com/chriskempson/base16-vim.git /tmp
mv /tmp/base16-vim/colors/* $HOME/.vim/colors
echo "...done!"

echo "LaTex Setup..."
sudo pacman -S texlive-core texlive-bin texlive-bibtexextra texlive-latexextra biber --noconfirm
echo "...done!"

echo "RVM Setup..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | sudo bash -s stable
cp ./home/rvmrc $HOME/.rvmrc

rvm install ruby
rvm --default use ruby
echo "...done!"
