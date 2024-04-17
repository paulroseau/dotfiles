#!/bin/bash

# Clone dotfiles repository
nix-shell -p git --command "git clone https://github.com/paulroseau/dotfiles $HOME/.dotfiles"
cd $HOME/.dotfiles

# Create links from .dotfiles to the right configs using stow (in particular the nix folder)
# Question how do you get your own version of stow at this point if not in nixpkgs?
# Stow configuration in $HOME
for package in $(ls configs)
do
  stow --dotfiles --dir configs --target $HOME $package # not working for now for dot-config cf. https://github.com/aspiers/stow/issues/33
  echo "$package stowed"
done

# Install applications
# TODO ask if you are installing on a remote workstation or locally (to install Alacritty)
nix-env -if nix/default.nix -A myPkgs.local


# Basic install script for Debian only

# Alacritty install
sudo ln -s $HOME/.nix-profile/share/applications/Alacritty.desktop /usr/local/share/applications/
sudo ln -s $HOME/.nix-profile/share/icons/hicolor/scalable/apps/Alacritty.svg /usr/share/pixmaps/

ln -s $HOME/.nix-profile/fonts $HOME/.fonts # Note: in https://www.youtube.com/watch?v=fR4ThXzhQYI the guy puts them in .local/share/fonts
rm $HOME/.cache/fontconfig/* # for good measure, spent hours understanding why fonts were not loaded
