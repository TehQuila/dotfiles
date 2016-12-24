#!/usr/bin/bash
read -n1 -p "Setup Monitors? [y/n] " monitors
if [[ "$monitors" == "y" ]]; then
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
         echo "   Option \"$side\" \"${screens[primary]}\"" | sudo tee --append $monitor_config
      fi
      echo "   Option \"DPMS\" \"true\"" | sudo tee --append $monitor_config
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


{
   echo "this is a test" >&3
   echo "second line" >&3

} 3>>test.txt
