#!/bin/bash

# Install nix

# Clone dotfiles repository

#nix-shell -p git --command "git clone https://github.com/paulroseau/dotfiles $HOME/.dotfiles"
#cd $HOME/.dotfiles

# Install applications
# TODO check if this works ?
# nix-env -if nix

# Stow configuration in $HOME
for package in $(ls configs)
do
  stow --dir configs --target $HOME $package
  echo "$package stowed"
done

# Basic install script for Ubuntu only

# Alacritty install
sudo ln -s $HOME/.nix-profile/share/applications/Alacritty.desktop /usr/local/share/applications/
sudo ln -s $HOME/.nix-profile/share/icons/hicolor/scalable/apps/Alacritty.svg /usr/share/pixmaps/
ln -s $HOME/.nix-profile/fonts $HOME/.font
rm $HOME/.cache/fontconfig/* # for good measure, spent hours understanding why fonts were not loaded
