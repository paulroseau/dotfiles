#!/bin/bash

check_command_exists () {
  if ! command -v ${1} >/dev/null 2>&1; then
    echo "Error: ${1} required but not found in PATH: ${PATH}." >&2
    exit 1
  fi
}

NIX_PROFILE="$HOME/.nix-profile"

check_command_exists "nix-env"
check_command_exists "nix-shell"

# Update PATH through nix-env if present
[ -r $NIX_PROFILE/etc/profile.d/nix.sh ] && . $NIX_PROFILE/etc/profile.d/nix.sh

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

clone_this_repository

create_config_symlinks
