#!/usr/bin/bash

cp ./home/gitconfig $HOME/.gitconfig
cp ./home/curlrc $HOME/.curlrc

sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm --needed

controller=$(lspci | grep -i vga)
if [[ "$(echo $controller | grep Intel -c)" ]]; then
   sudo pacman -S xf86-video-intel --noconfirm
elif [[ "$(echo $controller | grep ATI -c)" ]]; then
   sudo pacman -S xf86-video-ati --noconfirm
elif [[ "$(echo $controller | grep Nvidia -c)" ]]; then
   sudo pacman -S xf86-video-nouveau --noconfirm
else
   sudo pacman -S xf86-video-fbdev --noconfirm
fi

# TODO refine screen setup (setup Device/Screen section, identify place of monitor right/leftof)
sudo pacman -S xorg-xrandr --noconfirm
x_config="/etc/X11/xorg.conf.d/20-monitors.conf"
screens=()

while read -r line; do
   if [[ $line =~ ([A-Z]+[1-9])[[:space:]]connected ]]; then
      screens+=("${BASH_REMATCH[1]}")
   fi
done < <(xrandr)

echo "Choose primary screen: "
for i in ${!screens[@]}; do
   echo "($i) ${screens[i]}"
done
read primary

for i in ${!screens[@]}; do
   echo "Section \"Monitor\"" | sudo tee --append $x_config
   echo "   Identifier \"${screens[i]}\"" | sudo tee --append $x_config
   if [[ $i -eq $primary ]]; then
      echo "   Option \"Primary\" \"true\"" | sudo tee --append $x_config
   else
      echo "Option \"RightOf\" \"${screens[primary]}\"" | sudo tee --append $x_config
   fi
   echo "EndSection" | sudo tee --append $x_config
   echo "" | sudo tee --append $x_config
done

sudo pacman -S xterm xorg-xrdb xorg-xinit xorg-server --noconfirm

cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources

sudo pacman -S bash-completion --noconfirm
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/bashrc $HOME/.bashrc
cp ./home/toprc $HOME/.toprc

if [[ ! -d "$HOME/.config" ]]; then
   mkdir $HOME/.config
fi
git clone git://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell
base16_default_dark

sudo pacman -S i3 dmenu feh ttf-dejavu --noconfirm
cp -r ./home/i3 $HOME/.i3
cp -r ./home/fehbg $HOME/.fehbg

sudo pacman -S openssh unzip unrar keepass firefox vlc scrot ntfs-3g udisks2 udevil modprobe btusb --noconfirm
modprobe btusb

git clone https://aur.archlinux.org/package-query.git /tmp/package-query
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/package-query && exec makepkg -si)
(cd /tmp/yaourt && exec makepkg -si)

sudo pacman -S gvim --noconfirm
cp ./home/vimrc $HOME/.vimrc

mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

git clone git://github.com/vim-airline/vim-airline $HOME/.vim/bundle/vim-airline
git clone git://github.com/vim-airline/vim-airline-themes $HOME/.vim/bundle/vim-airline-themes
git clone git://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim
vim -u NONE -c "helptags vim-airline/doc" -c "helptags vim-airline-themes/doc" -c "helptags ctrlp.vim/doc" -c q

mkdir -p $HOME/.vim/colors
git clone git://github.com/chriskempson/base16-vim.git /tmp
mv /tmp/base16-vim/colors/* $HOME/.vim/colors

sudo pacman -S texlive-core texlive-bin texlive-bibtexextra texlive-latexextra biber --noconfirm


# TODO think about different optional software
echo "Setup a Printer? [y/n]"
read printer
if [[ "$printer" -eq "y" ]]; then
   sudo pacman -S cups avahi nss-mdns --noconfirm
   systemctl enable avahi-daemon.service
   systemctl enable org.cups.cupsd.service
   systemctl start avahi-daemon.service
   systemctl start org.cups.cupsd.service

   sudo lpinfo -v
   echo "Enter Printer name: "
   read queue_name
   echo "Paste Printer URI: "
   read uri

   sudo lpadmin -p $queue_name -E -v "$uri"
   sudo lpoptions -d $queue_name
   sudo cupsenable $queue_name
   sudo cupsaccept $queue_name
fi

echo "Setup Special Hardware Buttons? [y/n]"
read buttons
if [[ "$buttons" -eq "y" ]]; then
   sudo pacman -S xorg-xmodmap xbindkeys --noconfirm
   xmodmap -pke > ~/.Xmodmap # generate keycodes
   cp ./home/xbindkeysrc $HOME/.xbindkeysrc # bind keycodes
   sudo cp ./etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d
fi

echo "Setup audio? [y/n]"
read audio
if [[ "$audio" -eq "y" ]]; then
   sudo pacman -S alsa-utils --noconfirm
fi

echo "Setup folgin@home? [y/n]"
read fah
if [[ "$fah" -eq "n" ]]; then
   yaourt -S foldingathome --noconfirm
fi

echo "Setup Development tools? [y/n]"
read dev
if [[ "$dev" -eq "n" ]]; then
   gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
   curl -sSL https://get.rvm.io | sudo bash -s stable
   cp ./home/rvmrc $HOME/.rvmrc

   sudo pacman -S python nodejs npm --noconfirm
   yaourt -S datagrip rubymine pycharm-professional android-studio android-tools --noconfirm
   gpasswd -a tim adbusers
fi
