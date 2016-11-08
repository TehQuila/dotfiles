#!/usr/bin/bash

# TODO
# X11 scren turns black automatically
# bluetooth: https://bbs.archlinux.org/viewtopic.php?id=166678&p=2
# i3 open standard windows on every screen
# add Fn keys to xbindkeysrc
#add nfs mounting for NAS:
#sudo pacman -S nfs-utils
#systemctl start rpcbind
#write: "systemctl start rpcbind" in fstab

# Initialize pacman
sudo cp ./etc/pacman.conf /etc
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm --needed

# Install yaourt
git clone https://aur.archlinux.org/package-query.git /tmp/package-query
(cd /tmp/package-query && exec makepkg -si)
git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
(cd /tmp/yaourt && exec makepkg -si)

# Install packages
sudo pacman -S xorg-server --noconfirm
sudo pacman -S xorg-xinit --noconfirm
sudo pacman -S xorg-xrandr --noconfirm
sudo pacman -S xorg-xrdb --noconfirm
sudo pacman -S bash-completion --noconfirm
sudo pacman -S i3-wm --noconfirm
sudo pacman -S ttf-dejavu --noconfirm
sudo pacman -S ntfs-3g --noconfirm
sudo pacman -S xterm openssh biber i3lock i3status dmenu feh unzip unrar keepass scrot udisks2 udevil gvim --noconfirm
yaourt -S vivaldi --noconfirm

# Install optional packages
sudo pacman -S alsa-utils
yaourt -S foldingathome

echo "Setup LaTeX? [y/n]"
read latex
if [[ "$latex" -eq "y" ]]; then
   sudo pacman -S texlive-core --noconfirm
   sudo pacman -S texlive-bin --noconfirm
   sudo pacman -S texlive-bibtexextra --noconfirm
   sudo pacman -S texlive-latexextra --noconfirm
fi

# Install code from github
mkdir $HOME/.config
git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell

mkdir -p $HOME/.vim/autoload
mkdir -p $HOME/.vim/bundle
mkdir -p $HOME/.vim/colors

curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

git clone https://github.com/chriskempson/base16-vim.git /tmp/base16-vim
mv /tmp/base16-vim/colors/* $HOME/.vim/colors

git clone https://github.com/vim-airline/vim-airline $HOME/.vim/bundle/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes $HOME/.vim/bundle/vim-airline-themes
git clone https://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim

vim -u NONE -c "helptags $HOME/.vim/bundle/vim-airline/doc" -c "helptags $HOME/.vim/bundle/vim-airline-themes/doc" -c "helptags $HOME/.vim/bundle/ctrlp.vim/doc" -c q

# Execute setup commands

# Copy configs
cp ./home/gitconfig $HOME/.gitconfig
cp ./home/curlrc $HOME/.curlrc
cp ./home/xinitrc $HOME/.xinitrc
cp ./home/Xresources $HOME/.Xresources
cp ./home/bash_profile $HOME/.bash_profile
cp ./home/bashrc $HOME/.bashrc
cp -r ./home/i3 $HOME/.i3
cp ./home/fehbg $HOME/.fehbg
cp ./home/vimrc $HOME/.vimrc
cp ./home/toprc $HOME/.toprc
cp -rf ./home/config/vivaldi/Default $HOME/.config/Default

# Setup X11
sudo cp ./etc/X11/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d
sudo cp ./etc/X11/xorg.conf.d/01-mouse.conf /etc/X11/xorg.conf.d
echo "Setup Trackpoint/Touchpad/HW Button configs? [y/n]"
read laptop
if [[ "$laptop" -eq "y" ]]; then
   sudo cp ./etc/X11/xorg.conf.d/10-trackpoint.conf /etc/X11/xorg.conf.d
   sudo cp ./etc/X11/xorg.conf.d/11-touchpad.conf /etc/X11/xorg.conf.d
   sudo pacman -S xorg-xmodmap xbindkeys --noconfirm
   xmodmap -pke > $HOME/.Xmodmap # generate keycodes
   cp ./home/xbindkeysrc $HOME/.xbindkeysrc # bind keycodes
fi

# Setup Bluetooth
echo "Setup Bluetooth? [y/n]"
read bluetooth
if [[ "$bluetooth" -eq "y" ]]; then
   sudo pacman -S bluez bluez-utils dbus alsa-plugins pulseaudio pulseaudio-alsa
   modprobe btusb

   sudo systemctl enable dbus
   sudo systemctl start dbus
   dbus-daemon --session --fork

   sudo systemctl start bluetooth.service
fi

# Setup Monitors
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

echo "Setup Monitors? [y/n]"
read monitors
if [[ "$monitors" -eq "y" ]]; then
   monitor_config="/etc/X11/xorg.conf.d/20-monitors.conf"
   screens=()
   while read -r line; do
      if [[ $line =~ ([A-Z]+[1-9])[[:space:]]connected ]]; then
         screens+=("${BASH_REMATCH[1]}")
      fi
   done < <(xrandr)

   echo "Choose primary screen: "
   for i in${!screens[@]}; do
      echo "($i) ${screens[i]}"
   done
   read primary

   for i in ${!screens[@]}; do
      echo "Section \"Monitor\"" | sudo tee --append $monitor_config
      echo "   Identifier \"${screens[i]}\"" | sudo tee --append $monitor_config
      if [[ $i -eq $primary ]]; then
         echo "   Option \"Primary\" \"true\"" | sudo tee --append $monitor_config
      else
         echo "Screen ${screens[i]} right or left of primary? [LeftOf/RightOf]"
         read side
         echo "Option \"$side\" \"${screens[primary]}\"" | sudo tee --append $monitor_config
      fi
      echo "Option \"DPMS\" \"true\"" | sudo tee --append $monitor_config
      echo "EndSection" | sudo tee --append $monitor_config
      echo "" | sudo tee --append $monitor_config
   done

   echo "Section \"ServerLayout\"" >> sudo tee --append $monitor_config
   echo "   Identifier \"ServerLayout0\"" >> sudo tee --append $monitor_config
   echo "   Option \"StandbyTime\" \"0\"" >> sudo tee --append $monitor_config
   echo "   Option \"SuspendTime\" \"0\"" >> sudo tee --append $monitor_config
   echo "   Option \"OffTime\" \"0\"" >> sudo tee --append $monitor_config
   echo "   Option \"BlankTime\" \"0\"" >> sudo tee --append $monitor_config
   echo "EndSection" >> sudo tee --append $monitor_config
fi
