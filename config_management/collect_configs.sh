#!/usr/bin/bash

echo "Collecting Configs..."
WORKDIR=$(pwd)
DIR="${WORKDIR}/config_management"

cp /etc/pacman.conf $DIR/etc

cp /etc/X11/xorg.conf.d/00-keyboard.conf $DIR/etc/X11/xorg.conf.d
cp /etc/X11/xorg.conf.d/01-mouse.conf $DIR/etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/10-trackpoint.conf ]] && cp /etc/X11/xorg.conf.d/10-trackpoint.conf $DIR/etc/X11/xorg.conf.d
[[ -e /etc/X11/xorg.conf.d/11-touchpad.conf ]] && cp /etc/X11/xorg.conf.d/11-touchpad.conf $DIR/etc/X11/xorg.conf.d
# don't collect monitor since they are generated

# for xmodmap in setup_x11.sh
[[ -e $HOME/.xbindkeysrc ]] && cp $HOME/.xbindkeysrc $DIR/home/xbindkeysrc

cp /etc/sysctl.d/idea.conf $DIR/etc/sysctl.d

cp $HOME/.config/redshift.conf $DIR/home/config/redshift

cp $HOME/.bash_profile $DIR/home/bash_profile
cp $HOME/.xinitrc $DIR/home/xinitrc
cp $HOME/.Xresources $DIR/home/Xresources
cp $HOME/.bashrc $DIR/home/bashrc
cp $HOME/.ssh/config $DIR/home/ssh/config
cp -r $HOME/.i3/* $DIR/home/i3
cp $HOME/.gitconfig $DIR/home/gitconfig
cp $HOME/.curlrc $DIR/home/curlrc
cp $HOME/.toprc $DIR/home/toprc
cp $HOME/.vimrc $DIR/home/vimrc
[[ -e $HOME/.rvmrc ]] && cp $HOME/.rvmrc $DIR/home/rvmrc

FF=".mozilla/firefox"
P="2n3roeyr.default"
cp $HOME/$FF/profiles.ini $DIR/home/mozilla/firefox
cp $HOME/$FF/$P/search.json.mozlz4 $DIR/home/mozilla/firefox/$P
cp $HOME/$FF/$P/permissions.sqlite $DIR/home/mozilla/firefox/$P
cp $HOME/$FF/$P/content-prefs.sqlite $DIR/home/mozilla/firefox/$P
cp $HOME/$FF/$P/mimeTypes.rdf $DIR/home/mozilla/firefox/$P
cp $HOME/$FF/$P/xulstore.json $DIR/home/mozilla/firefox/$P
cp $HOME/$FF/$P/prefs.js $DIR/home/mozilla/firefox/$P
cp -r $HOME/$FF/$P/extensions $DIR/home/mozilla/firefox/$P
