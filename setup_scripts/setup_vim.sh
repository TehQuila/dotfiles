#!/usr/bin/bash

sudo pacman -S gvim --noconfirm

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
