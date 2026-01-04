#!/bin/bash

check_command_exists () {
  if ! command -v ${1} >/dev/null 2>&1; then
    echo "Error: ${1} required but not found in PATH: ${PATH}." >&2
    exit 1
  fi
}

NIX_PROFILE="$HOME/.nix-profile"

# Update PATH through nix-env if present
[ -r $NIX_PROFILE/etc/profile.d/nix.sh ] && . $NIX_PROFILE/etc/profile.d/nix.sh

check_command_exists "nix-env"
check_command_exists "nix-shell"

clone_this_repository () {
  nix-shell -p git --command "git clone https://github.com/paulroseau/dotfiles $HOME/.dotfiles"
}

create_config_symlinks () {
  pushd $HOME/.dotfiles
  for package in $(ls configs); do
    nix-shell -p stow --command "stow --dotfiles --dir configs --target $HOME $package"
    echo "$package stowed"
  done
  popd
}

install_binaries () {
  # TODO select which bundle to install
  nix-env --install --file '<nixpkgs>' --attr neovim-plugins
}

link_nvim_package_to_nix_installed () {
  NVIM_PACKAGES_DIR_PREFIX="$HOME/.local"
  NVIM_PACKAGES_DIR_SUFFIX="share/nvim/site/pack"
  NVIM_PACKAGES_DIR="$NVIM_PACKAGES_DIR_PREFIX/$NVIM_PACKAGES_DIR_SUFFIX"

  NIX_INSTALLED_NVIM_PACKAGE_DIR="$NIX_PROFILE/$NVIM_PACKAGES_DIR_SUFFIX"

  mkdir -p $NVIM_PACKAGES_DIR
  for package in $(ls $NIX_INSTALLED_NVIM_PACKAGE_DIR); do
    ln -s $NIX_INSTALLED_NVIM_PACKAGE_DIR/$package $NVIM_PACKAGES_DIR 
  done
}

clone_this_repository
create_config_symlinks
install_binaries
link_nvim_package_to_nix_installed
