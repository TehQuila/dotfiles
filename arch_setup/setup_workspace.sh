printf "Enter your github email: "
read email

firefox -new-window https://github.com/settings/keys
ssh-keygen -t rsa -b 4096 -C $email
cat $HOME/.ssh/id_rsa.pub

read -n1 -r -p "Press any key to continue..." key

git clone git@github.com:TehQuila/lettertemplate.git $HOME/workspace/lettertemplate
git clone git@github.com:TehQuila/curriculumvitae.git $HOME/workspace/curriculumvitae
git clone git@github.com:TehQuila/projecteuler.git $HOME/workspace/projecteuler

sudo gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | sudo bash -s stable
sudo gpasswd -a $USER rvm
cp ./home/rvmrc $HOME/.rvmrc


sudo pacman -S python nodejs npm --noconfirm

yaourt -S webstorm datagrip intellij-idea-ultimate-edition clion rubymine pycharm-professional android-studio android-tools --noconfirm
sudo gpasswd -a $USER adbusers
