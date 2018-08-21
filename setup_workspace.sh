printf "Enter your github email: "
read EMAIL

firefox -new-window https://github.com/settings/keys
ssh-keygen -t rsa -b 4096 -C $EMAIL
cat $HOME/.ssh/id_rsa.pub

read -n1 -r -p "Press any key to continue..." key

read -n1 -p "Setup Ruby? [y/n] " ruby
if [[ "$ruby" == "y" ]]; then
   sudo pacman -S ruby --noconfirm

   aurman -S rubymine --noconfirm

   sudo gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
   curl -sSL https://get.rvm.io | sudo bash -s stable
   sudo gpasswd -a $USER rvm
   cp ./home/rvmrc $HOME/.rvmrc
fi

read -n1 -p "Setup Python? [y/n] " python
if [[ "$python" == "y" ]]; then
   sudo pacman -S python --noconfirm
   aurman -S pycharm-professional --noconfirm
fi

read -n1 -p "Setup Go? [y/n] " go
if [[ "$go" == "y" ]]; then
   sudo pacman -S go --noconfirm
   aurman -S goland --noconfirm
fi

read -n1 -p "Setup Angular? [y/n] " angular
if [[ "$angular" == "y" ]]; then
   sudo pacman -S nodejs npm --noconfirm
   aurman -S angular-cli --noconfirm
   aurman -S webstorm --noconfirm
fi

read -n1 -p "Setup Android? [y/n] " android
if [[ "$android" == "y" ]]; then
   aurman -S android-studio --noconfirm
   aurman -S android-tools --noconfirm
   sudo gpasswd -a $USER adbusers
fi
