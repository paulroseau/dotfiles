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

download_archive_from_github() {
  owner=$1
  repo=$2
  version=$3
  archive=$4

  echo "Installing ${repo} (${archive}) from Github"
  mkdir -p ${APPS_STORE}/${repo}
  curl -sSLO https://github.com/${owner}/${repo}/releases/download/${version}/${archive}
  case ${archive} in
    *.tar.gz | *.tgz )
      tar -zxf ${archive} --directory ${APPS_STORE}/${repo}
      ;;
    *.zip )
      unzip -oq ${archive} -d ${APPS_STORE}/${repo}
      ;;
  esac
  rm ${archive}
}

install_binary_from_github() {
  owner=$1
  repo=$2
  version=$3
  archive=$4
  bin_parent_directory_name=$5

  download_archive_from_github $owner $repo $version $archive

  bin_parent_path=${APPS_STORE}/${repo}/${bin_parent_directory_name}

  for bin_name in $(ls ${bin_parent_path})
  do
    file=${bin_parent_path}/${bin_name}
    test -x $file && ln -sf $file $ENVIRONMENT_HOME/bin
  done
}

install_binaries_from_github() {
  echo "Installing binaires from Github"

  install_binary_from_github neovim neovim v0.11.1 nvim-linux-x86_64.tar.gz nvim-linux-x86_64/bin

  install_binary_from_github LuaLS lua-language-server 3.14.0 lua-language-server-3.14.0-linux-x64.tar.gz bin

  install_binary_from_github clangd clangd 19.1.2 clangd-linux-19.1.2.zip clangd_19.1.2/bin

  install_binary_from_github mikefarah yq v4.45.4 yq_linux_amd64.tar.gz .
  mv $ENVIRONMENT_HOME/bin/yq_linux_amd64 $ENVIRONMENT_HOME/bin/yq

  # todo install wezterm
  echo "Done"
}

download_archives_from_github() {
  echo "Downloading source archives from Github"
  install_binary_from_github jonas tig tig-2.5.12 tig-2.5.12.tar.gz
  install_binary_from_github tmux tmux 3.5a tmux-3.5a.tar.gz
  echo "Done"
}

install_rust() {
  echo "Installing Rust toolchain"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . ~/.cargo/env
}

install_rust_built_binaries() {
  echo "Installing Rust build binaries"
  cargo install bat --version 0.25.0
  cargo install fd-find --version 10.2.0
  cargo install git-delta --version 0.18.2
  cargo install jaq --version 2.2.0
  cargo install ripgrep --version 14.1.1
  cargo install skim --version $SKIM_VERSION
  cargo install starship --version 1.23.0
  cargo install zoxide --version 0.9.8
  echo "Done"
}

clone_this_repository() {
  echo "Cloning github.com/paulroseau/dotfiles"
  git clone --quiet https://github.com/paulroseau/dotfiles.git $DOTFILES
}

symlink_config_files() {
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
  echo "Done"
}

install_skim_shell_bindings() {
  echo "Installing skim shell bindings"
  SKIM_TMP_DIR=$(mktemp --directory /tmp/skim-src-XXXX)
  git clone --quiet --depth 1 --branch "v${SKIM_VERSION}" https://github.com/skim-rs/skim.git $SKIM_TMP_DIR 2>/dev/null
  mkdir -p $SKIM_SHELL_DIR
  cp $SKIM_TMP_DIR/shell/* $SKIM_SHELL_DIR
  rm -rf $SKIM_TMP_DIR
}

# TODO
alias jq='jaq'
download_zsh_plugins() {
  echo "Downloading ZSH plugins"
  # $DOTFILES/scripts/get-plugins.sh
  echo "Done"
}

download_nvim_plugins() {
  echo "Downloading Neovim plugins"
  echo "Done"
}

create_ssh_key() {
  echo "Generating ssh key"
  ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -N ""
  echo "Export the following key to Github, Gitlab, Bitbucket"
  /bin/cat $HOME/.ssh/id_rsa.pub
}

clone_this_repository
symlink_config_files
. $HOME/.env
install_binaries_from_github
install_rust
install_rust_built_binaries
install_skim_shell_bindings
# download_zsh_plugins
# download_nvim_plugins
create_ssh_key
