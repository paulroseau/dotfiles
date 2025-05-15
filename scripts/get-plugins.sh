#!/usr/bin/env zsh

if [[ -z "$ZSH_PLUGINS_DIR" || -z "$NVIM_PLUGINS_DIR" ]] ; then source ~/.zshrc ; fi

function clone_and_update_repo {
  plugin_name=$1
  owner=$2
  repo=$3
  rev=$4
  target_dir=$5

  if [ ! -d "${target_dir}/${plugin_name}" ]; then
    echo "${target_dir}/${plugin_name} does not exist, cloning it"
    git clone --quiet https://github.com/${owner}/${repo} ${target_dir}/${plugin_name}
    echo "${target_dir}/${plugin_name} cloned"
  fi

  pushd ${target_dir}/${plugin_name}
  git fetch --quiet
  git checkout --quiet $rev
  echo "${target_dir}/${plugin_name} checked to version ${rev}"
  popd
}

function clone_and_update_repos {
  plugin_sources_json=$1
  target_dir=$2

  if [ ! -d " $target_dir )" ]; then
    mkdir -p $target_dir
  fi

  cat $plugin_sources_json | jq -r 'to_entries[] | "\(.key) \(.value | .owner) \(.value | .repo) \(.value | .rev)"' | while read -r plugin_name owner repo rev
  do
    clone_and_update_repo $plugin_name $owner $repo $rev $target_dir
  done
}

NVIM_PLUGINS_SOURCES_JSON="${0:a:h}/plugins-sources/neovim.json"
ZSH_PLUGINS_SOURCES_JSON="${0:a:h}/plugins-sources/zsh.json"

if [[ "$ZSH_PLUGINS_DIR" == "$HOME/.nix-profile/share" ]]
then
  echo "zsh plugins seem to be already managed by Nix, aborting"
  exit 1
else
  clone_and_update_repos $ZSH_PLUGINS_SOURCES_JSON $ZSH_PLUGINS_DIR
fi

if [[ "$NVIM_PLUGINS_DIR" == "$HOME/.nix-profile/share/neovim-plugins" ]]
then
  echo "Neovim plugins seem to be already managed by Nix, aborting"
  exit 1
else
  clone_and_update_repos $NVIM_PLUGINS_SOURCES_JSON $NVIM_PLUGINS_DIR
fi
