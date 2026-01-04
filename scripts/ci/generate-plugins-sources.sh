#!/bin/bash

CURRENT_DIR=$(realpath $(dirname $0))
PLUGINS_SOURCES_FILE="${CURRENT_DIR}/../plugins-sources.json"

nix eval --raw --impure --expr '
  let pkgs = import <nixpkgs> {};
  in builtins.toJSON pkgs.plugins-sources
' | jq > ${PLUGINS_SOURCES_FILE}

echo "The following repositories don't have valid github information available, you need to update ${PLUGINS_SOURCES_FILE} manually"
echo -e "\nNeovim plugins:"
cat ${PLUGINS_SOURCES_FILE} | jq '.neovim | with_entries(select(.value | objects and any(.[]; . == null)))'

echo -e "\nZsh plugins:"
cat ${PLUGINS_SOURCES_FILE} | jq '.zsh | with_entries(select(.value | objects and any(.[]; . == null)))'
