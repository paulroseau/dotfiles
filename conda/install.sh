#!/bin/bash

# Pre-install script start with Docker image condaforge/miniforge-pypy3
conda install -n base conda-forge::git
git clone https://github.com/paulroseau/dotfiles ~/.dotfiles

cd ~/.dotfiles/conda

conda env update -n base -f ./environment.yaml

# Set up config files (a la mano since stow is not 2.4.x)
for package in $(ls configs)
do
  stow --dotfiles --dir configs --target $HOME $package
  echo "$package stowed"
done

# Install nvim and zsh plugins (issue with ssl certificate chain)
./scripts/get-plugins.sh
