#!/usr/bin/bash

sudo pacman -S xorg-server --noconfirm
sudo pacman -S xorg-xinit --noconfirm
sudo pacman -S xorg-xrandr --noconfirm
sudo pacman -S xorg-xrdb --noconfirm

read -n1 -p "Setup Trackpoint/Touchpad/HW Button configs? [y/n] " laptop
if [[ "$laptop" == "y" ]]; then
   sudo cp ./etc/X11/xorg.conf.d/10-trackpoint.conf /etc/X11/xorg.conf.d
   sudo cp ./etc/X11/xorg.conf.d/11-touchpad.conf /etc/X11/xorg.conf.d
   sudo pacman -S xorg-xmodmap xbindkeys --noconfirm
   xmodmap -pke > $HOME/.Xmodmap # generate keycodes
   cp ./home/xbindkeysrc $HOME/.xbindkeysrc # bind keycodes
fi

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

read -n1 -p "Setup Monitors? [y/n] " monitors
if [[ "$monitors" == "y" ]]; then
   screens=()
   while read -r line; do
      if [[ $line =~ (([A-Z]+[-])+[1-9])[[:space:]]connected ]]; then
         screens+=("${BASH_REMATCH[1]}")
      fi
   done < <(xrandr)

   echo ""

   for i in ${!screens[@]}; do
      echo "($i) ${screens[i]}"
   done
   read -n1 -p "Choose primary screen: " primary

   echo ""

   {
      for i in ${!screens[@]}; do
         sudo echo "Section \"Monitor\"" >&3
         sudo echo "   Identifier \"${screens[i]}\"" >&3
         if [[ $i -eq $primary ]]; then
            sudo echo "   Option \"Primary\" \"true\"" >&3
         else
            read -n1 -p "${screens[i]} right or left of ${screens[primary]}? [l/r] " side
            echo ""
            if [[ $side == "l" ]]; then
               sudo echo "   Option \"LeftOf\" \"${screens[primary]}\"" >&3
            elif [[ $side == "r" ]]; then
               sudo echo "   Option \"RightOf\" \"${screens[primary]}\"" >&3
            fi
         fi
         sudo echo "   Option \"DPMS\" \"true\"" >&3
         sudo echo "EndSection" >&3
         sudo echo "" >&3
      done

      sudo echo "Section \"ServerLayout\"" >&3
      sudo echo "   Identifier \"ServerLayout0\"" >&3
      sudo echo "   Option \"StandbyTime\" \"0\"" >&3
      sudo echo "   Option \"SuspendTime\" \"0\"" >&3
      sudo echo "   Option \"OffTime\" \"0\"" >&3
      sudo echo "   Option \"BlankTime\" \"0\"" >&3
      sudo echo "EndSection" >&3

   } 3>>/etc/X11/xorg.conf.d/20-monitors.conf
fi
