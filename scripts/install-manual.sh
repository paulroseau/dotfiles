#!/bin/sh

# Prerequisites:
# - curl
# - git
# Not installed (blocked by office proxy): zsh

APPS_STORE=$HOME/store
mkdir -p $APPS_STORE

ENVIRONMENT_HOME=$HOME/.local
mkdir -p $ENVIRONMENT_HOME/bin

SKIM_VERSION="0.18.0"
DOTFILES=$HOME/.dotfiles

function install_binary_from_github () {
  owner=$1
  repo=$2
  version=$3
  archive=$4

  mkdir -p $APPS_STORE/${repo}
  curl -sSLO https://github.com/${owner}/${repo}/releases/download/${version}/${archive}
  tar -zxf ${archive} --directory ${APPS_STORE}/${repo}
  ln -s $APPS_STORE/${repo}/bin/* $ENVIRONMENT_HOME/bin/
}

function install_binaries_from_github () {
  echo "Installing binaires from Github"
  install_binary_from_github neovim neovim v0.11.1 nvim-linux-x86_64.tar.gz
  install_binary_from_github jonas tig v2.5.12 tig-2.5.12.tar.gz
  install_binary_from_github tmux tmux 3.5a tmux-3.5a.tar.gz
  install_binary_from_github LuaLS lua-language-server 3.14.0 lua-language-server-3.14.0-linux-x64.tar.gz
  # todo install wezterm
}

function install_rust () {
  echo "Installing Rust toolchain"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source ~/.cargo/env
}

function install_rust_built_binaries () {
  echo "Installing Rust build binaries"
  cargo install bat --version 0.25.0
  cargo install fd-find --version 10.2.0
  cargo install git-delta --version 0.18.2
  cargo install jaq --version 2.2.0
  cargo install ripgrep --version 14.1.1
  cargo install skim --version $SKIM_VERSION
  cargo install starship --version 1.23.0
  cargo install zoxide --version 0.9.8
}

function clone_this_repository () {
  echo "Cloning github.com/paulroseau/dotfiles"
  git clone --quiet https://github.com/paulroseau/dotfiles.git $DOTFILES
}

function symlink_config_files () {
  echo "Creating config files symlinks"
  ln -sf $DOTFILES/configs/shells/dot-env $HOME/.env
  ln -sf $DOTFILES/configs/shells/dot-aliases $HOME/.aliases
  ln -sf $DOTFILES/configs/shells/dot-bashrc $HOME/.bashrc
  ln -sf $DOTFILES/configs/shells/dot-zshrc $HOME/.zshrc
  ln -sf $DOTFILES/configs/tmux/dot-tmux.conf $HOME/.tmux.conf
  ln -sf $DOTFILES/configs/nvim/dot-config/nvim $HOME/.config
  ln -sf $DOTFILES/configs/starship/dot-config/starship.toml $HOME/.config
  ln -sf $DOTFILES/configs/git/dot-gitconfig $HOME/.gitconfig
  ln -sf $DOTFILES/configs/git/dot-config/git $HOME/.config
}

function install_skim_shell_bindings () {
  echo "Installing skim shell bindings"
  SKIM_TMP_DIR=$(mktemp --directory /tmp/skim-shells-XXXX)
  git clone --quiet --depth 1 --branch "v${SKIM_VERSION}" https://github.com/skim-rs/skim.git $SKIM_TMP_DIR
  cp $SKIM_TMP_DIR/skim/shell/* $SKIM_SHELL_DIR
  rm -rf $SKIM_TMP_DIR
}

# TODO
alias jq='jaq'
$DOTFILES/scripts/get-plugins.sh
function download_zsh_plugins () {
  echo "Downloading ZSH plugins"
}

function download_nvim_plugins () {
  echo "Downloading Neovim plugins"
}

function create_ssh_key () {
  echo "Generating ssh key"
  ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -N ""
  echo "Export the following key to Github, Gitlab, Bitbucket"
  /bin/cat $HOME/.ssh/id_rsa.pub
}

clone_this_repository
symlink_config_files
source $HOME/.env
install_binaries_from_github
install_rust
install_rust_built_binaries
install_skim_shell_bindings
download_zsh_plugins
download_nvim_plugins
create_ssh_key
