#!/bin/bash

NIX_PROFILE="$HOME/.nix-profile"

# Update PATH through nix-env if present
[ -r $NIX_PROFILE/etc/profile.d/nix.sh ] && . $NIX_PROFILE/etc/profile.d/nix.sh

if ! command -v nix-env >/dev/null 2>&1; then
  echo "Error: nix-env not found in PATH, install Nix." >&2
  exit 1
fi

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
nix-env -f '<nixpkgs>' --install --attr bundle.base
