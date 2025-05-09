#!/bin/bash

set -xe

source $HOME/.nix-profile/etc/profile.d/nix.sh

WORKDIR=$(dirname $0)
cd ${WORKDIR}

nix-env -if nix/default.nix -A $1
nix-collect-garbage --delete-old

for package in $(ls configs)
do
  stow --dotfiles --dir configs --target $HOME $package
  echo "$package stowed"
done
