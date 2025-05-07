#!/bin/bash

DOTFILES_HOME="${DOTFILES_HOME:-$HOME/.dotfiles}"
PLUGINS_SOURCES_JSON=${DOTFILES_HOME}/nix/packages/neovim-plugins/plugins/sources.json

# Hack! This path is hardcoded in ~/.config/nvim/init.lua because our
# config expects plugins to be downloaded by nix and to be already available
# under this path
TARGET_DIR="${TARGET_DIR:-$HOME/.nix-profile/share/neovim-plugins}"

if [ -z "$( ls -A $TARGET_DIR )" ]; then
   mkdir -p $TARGET_DIR
fi

function install_neovim_plugin {
  plugin_name=$1
  owner=$2
  repo=$3
  rev=$4
  target_dir=$5

  if [ ! -d "${target_dir}/${plugin_name}" ]; then
    echo "${target_dir}/${plugin_name} does not exist, cloning it"
    git clone https://github.com/${owner}/${repo} ${target_dir}/${plugin_name}
  fi

  cd ${target_dir}/${plugin_name}
  git checkout $rev
  cd -
}

cat $PLUGINS_SOURCES_JSON | jq -r 'to_entries[] | "\(.key) \(.value | .owner) \(.value | .repo) \(.value | .rev)"' | while read -r plugin_name owner repo rev
do
  install_neovim_plugin $plugin_name $owner $repo $rev $TARGET_DIR
done
