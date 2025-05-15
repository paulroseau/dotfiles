#!/bin/bash

### MANUAL PART ####
# # Pre-install script start with Docker image condaforge/miniforge-pypy3
# # Until we properly investigate this certificate issue
# git clone -c http.sslVerify=false https://github.com/paulroseau/dotfiles ~/.dotfiles
### MANUAL PART ####

ln -s ~/.dotfiles/configs/conda/dot-condarc ~/.condarc
conda create --name default
conda init
conda activate default
source ~/.bashrc

# Set up config files (a la mano since stow is not 2.4.x)
# for package in $(ls configs)
# do
#   stow --dotfiles --dir configs --target $HOME $package
#   echo "$package stowed"
# done

if [ -f ~/.zshrc ]; then rm ~/.zshrc ; fi
ln -s ~/.dotfiles/configs/zsh/dot-zshrc ~/.zshrc
ln -s ~/.dotfiles/configs/tmux/dot-tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/configs/nvim/dot-config/nvim ~/.config/
ln -s ~/.dotfiles/configs/starship/dot-config/starship.toml ~/.config/
ln -s ~/.dotfiles/configs/git/dot-gitconfig ~/.gitconfig
ln -s ~/.dotfiles/configs/git/dot-config/git/ ~/.config/

# Install nvim and zsh plugins (issue with ssl certificate chain)
~/.dotfiles/scripts/get-plugins.sh

# Create ssh key
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
echo "Copy the following to Gitlab"
/bin/cat ~/.ssh/id_rsa.pub
