#!/usr/bin/bash

# install gvim for clipboard support
sudo pacman -S gvim --noconfirm

mkdir -p $HOME/.vim/colors
git clone https://github.com/chriskempson/base16-vim.git /tmp/base16-vim
mv /tmp/base16-vim/colors/* $HOME/.vim/colors

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# todo: vimrc must be installed first
vim +'PlugInstall --sync' +qa
