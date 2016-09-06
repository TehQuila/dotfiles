#!/usr/bin/bash

# TODO setup laptop specific stuff
echo "Setting up laptop? [y/n]"
read LAPTOP

echo "Preparing Setup..."
su -c "pacman -S sudo"
su -c "visudo"

sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu

# setup utils needed for installation
sudo pacman -S git curl
cp ./home/gitconfig $HOME/.gitconfig
cp ./home/curlrc $HOME/.curlrc
echo "...done!"

echo "X11 Setup..."
sudo pacman -S xorg-xinit xorg-server xorg-xrandr

if [[ "$LAPTOP" -eq "y" ]]; then
   sudo pacman -S xorg-xmodmap xbindkeys
   xmodmap -pke > ~/.Xmodmap # generate keycodes
   cp ./home/xbindkeysrc $HOME/.xbindkeysrc # bind keycodes
   sudo cp ./etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d
fi

# TODO query available monitors and generate xorg.conf
echo "...done!"

echo "Bash Setup..."
sudo pacman -S xterm xorg-xrdb xinit bash-completion
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources
cp ./home/bashrc $HOME/.bashrc
cp ./home/toprc $HOME/.toprc

git clone git://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
echo "...done!"

echo "GUI Setup..."
sudo pacman -S i3 dmenu feh alsa-utils ttf-dejavu
cp -r ./home/i3 $HOME/.i3
cp -r ./home/fehbg $HOME/.fehbg
echo "...done!"

echo "Installing utilities..."
sudo pacman -S unzip unrar keepass chromium vlc scrot ntfs-3g udisks2 udevil xclip
echo "...done!"

echo "Setting up Bluetooth..."
sudo pacman -S modprobe btusb
modprobe btusb
echo "...done!"

echo "Setup Yaourt..."
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/package-query && exec makepkg -si)
(cd /tmp/yaourt && exec makepkg -si)
echo "...done!"

# Install AUR packages
if [[ "$LAPTOP" -eq "n" ]]; then
   yaourt -S folingathome
fi

echo "VIM Setup..."
sudo pacman -S vim
cp ./home/vimrc $HOME/.vimrc

# install vim package manager
mkdir -p $HOME/.vim/autoload
curl -LSso ~/.vim/autoload/pathogen.vim https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

# install packages
mkdir -p $HOME/.vim/bundle
git clone git://github.com/tpope/vim-fugitive.git $HOME/.vim/bundle/vim-fugitive
git clone git://github.com/vim-airline/vim-airline $HOME/.vim/bundle/vim-airline
git clone git://github.com/vim-airline/vim-airline-themes $HOME/.vim/bundle/vim-airline-themes
git clone git://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim
vim -u NONE -c "helptags vim-fugitive/doc" -c "helptags vim-airline/doc" -c "helptags vim-airline-themes/doc" -c "helptags ctrlp.vim/doc" -c q

# install color suite
mkdir -p $HOME/.vim/colors
git clone git://github.com/chriskempson/base16-vim.git $HOME/.vim/colors
echo "...done!"

echo "LaTex Setup..."
sudo pacman -S texlive-core texlive-bin texlive-bibtexextra texlive-latexextra biber
echo "...done!"

echo "RoR Setup..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | sudo bash -s stable
sudo usermod -a -G rvm `id -u -n`
if sudo grep -q secure_path /etc/sudoers; then
   sudo sh -c "echo export rvmsudo_secure_path=1 >> /etc/profile.d/rvm_secure_path.sh"
   echo "Environment variable installed"
fi
cp ./home/rvmrc $HOME/.rvmrc
source /etc/profile.d/rvm.sh
rvm install ruby
rvm --default use ruby
sudo pacman -S nodejs
echo "...done!"
