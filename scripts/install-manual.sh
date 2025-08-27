#!/bin/sh

# Prerequisites:
# - gcc
# - git
# - curl
# - xz-utils
# - unzip
# Not installed (blocked by office proxy): zsh

APPS_STORE=$HOME/store
mkdir -p $APPS_STORE

ENVIRONMENT_HOME=$HOME/.local
mkdir -p $ENVIRONMENT_HOME/bin

SKIM_VERSION="0.18.0"
FZF_VERSION="0.62.0"

DOTFILES=$HOME/.dotfiles

download_archive() {
  url=$1
  archive=$2
  target_dir=$3

  echo "Downloading ${url}"
  mkdir -p ${target_dir}
  curl -sSLO ${url}/${archive}
  case ${archive} in
    *.tar.gz | *.tgz )
      tar -zxf ${archive} --directory ${target_dir}
      rm ${archive}
      ;;
    *.tar.xz )
      xz --decompress ${archive} --stdout | tar -x --directory ${target_dir}
      rm ${archive}
      ;;
    *.zip )
      unzip -oq ${archive} -d ${target_dir}
      rm ${archive}
      ;;
    * )
      # Assume we download the executable directly
      mv ${archive} ${target_dir}
      chmod +x ${target_dir}/${archive}
  esac
}

install_binary() {
  url=$1
  archive=$2
  target_dir=$3
  bin_parent_directory_name=$4

  download_archive ${url} ${archive} ${target_dir}

  bin_parent_path=${target_dir}/${bin_parent_directory_name}

  for bin_name in $(ls ${bin_parent_path})
  do
    file=${bin_parent_path}/${bin_name}
    test -x $file && ln -sf $file $ENVIRONMENT_HOME/bin
  done
}

install_binaries() {
  echo "Installing binaires from Github"

  NVIM_VERSION="0.11.1"
  install_binary \
    "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}" \
    nvim-linux-x86_64.tar.gz \
    ${APPS_STORE}/neovim-${NVIM_VERSION} \
    nvim-linux-x86_64/bin

  LUA_LS_VERSION="3.14.0"
  install_binary \
    "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}" \
    lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz \
    ${APPS_STORE}/lua-language-server-${LUA_LS_VERSION} \
    bin

  install_binary \
    "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}" \
    fzf-${FZF_VERSION}-linux_amd64.tar.gz \
    ${APPS_STORE}/fzf-${FZF_VERSION} \
    .

  CLANGD_VERSION="19.1.2"
  install_binary \
    "https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}" \
    clangd-linux-${CLANGD_VERSION}.zip \
    ${APPS_STORE}/clangd-${CLANGD_VERSION} \
    clangd_${CLANGD_VERSION}/bin

  YQ_VERSION="4.45.4"
  install_binary \
    "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}" \
    yq_linux_amd64.tar.gz \
    ${APPS_STORE}/yq-${YQ_VERSION} \
    .
  mv $ENVIRONMENT_HOME/bin/yq_linux_amd64 $ENVIRONMENT_HOME/bin/yq

  WEZTERM_VERSION="20240203-110809-5046fc22"
  install_binary \
    "https://github.com/wezterm/wezterm/releases/download/${WEZTERM_VERSION}" \
    wezterm-${WEZTERM_VERSION}.Ubuntu20.04.tar.xz \
    ${APPS_STORE}/wezterm-${WEZTERM_VERSION} \
    wezterm/usr/bin

  TERRAFORM_LS_VERSION="0.36.4"
  install_binary \
    https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION} \
    terraform-ls_${TERRAFORM_LS_VERSION}_linux_amd64.zip \
    ${APPS_STORE}/terraform-ls-${TERRAFORM_LS_VERSION} \
    .

  echo "Done"
}

install_work_binaries() {
  echo "Installing work binaries from Github"

  KIND_VERSION="v0.29.0"
  install_binary \
    https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION} \
    kind-linux-amd64 \
    ${APPS_STORE}/kind-${KIND_VERSION} \
    .
  mv $ENVIRONMENT_HOME/bin/kind-linux-amd64 $ENVIRONMENT_HOME/bin/kind

  HELM_VERSION="v3.18.6"
  install_binary \
    https://get.helm.sh \
    helm-${HELM_VERSION}-linux-amd64.tar.gz \
    ${APPS_STORE}/helm-${HELM_VERSION} \
    linux-amd64

  echo "Done"
}

install_rust() {
  echo "Installing Rust toolchain"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . ~/.cargo/env
  echo "Done"
}

install_rust_built_applications() {
  echo "Installing Rust build binaries"
  cargo install bat --version 0.25.0
  cargo install fd-find --version 10.2.0
  cargo install git-delta --version 0.18.2
  cargo install jaq --version 2.2.0
  cargo install ripgrep --version 14.1.1
  cargo install skim --version $SKIM_VERSION
  cargo install starship --version 1.23.0
  cargo install yazi-fm yazi-cli --version 25.4.8
  cargo install zoxide --version 0.9.8
  echo "Done"
}

install_node() {
  echo "Installing nvm"
  NVM_VERSION="0.40.3"
  git clone --quiet --depth 1 --branch "v${NVM_VERSION}" https://github.com/nvm-sh/nvm.git "$NVM_DIR" 2>/dev/null
  . "$NVM_DIR/nvm.sh"
  echo "Done"

  echo "Installing node and npm through nvm"
  nvm install node

  for bin in $(ls "$NVM_BIN"); do
    ln -sf $NVM_BIN/$bin $ENVIRONMENT_HOME/bin
  done
  echo "Done"
}

install_node_applications() {
  echo "Installing node applications"

  . "$NVM_DIR/nvm.sh"

  npm install --global vscode-langservers-extracted@v4.10.0
  npm install --global prettier@3.6.2
  npm install --global yaml-language-server@1.18.0
  npm install --global gitmoji-cli@v9.7.0

  for bin in $(ls "$NVM_BIN"); do
    ln -sf $NVM_BIN/$bin $ENVIRONMENT_HOME/bin
  done
  echo "Done"
}

clone_this_repository() {
  echo "Cloning github.com/paulroseau/dotfiles"
  git clone --quiet https://github.com/paulroseau/dotfiles.git $DOTFILES
  echo "Done"
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
  ln -sf $DOTFILES/configs/yazi/dot-config/yazi $HOME/.config
  echo "Done"
}

install_skim_shell_bindings() {
  echo "Installing skim shell bindings"
  SKIM_TMP_DIR=$(mktemp --directory /tmp/skim-src-XXXX)
  git clone --quiet --depth 1 --branch "v${SKIM_VERSION}" https://github.com/skim-rs/skim.git $SKIM_TMP_DIR 2>/dev/null
  mkdir -p $SKIM_SHELL_DIR
  cp $SKIM_TMP_DIR/shell/* $SKIM_SHELL_DIR
  rm -rf $SKIM_TMP_DIR
  echo "Done"
}

install_fzf_shell_bindings() {
  echo "Installing fzf shell bindings"
  FZF_TMP_DIR=$(mktemp --directory /tmp/fzf-src-XXXX)
  git clone --quiet --depth 1 --branch "v${FZF_VERSION}" https://github.com/junegunn/fzf.git $FZF_TMP_DIR 2>/dev/null
  mkdir -p $FZF_SHELL_DIR
  cp $FZF_TMP_DIR/shell/* $FZF_SHELL_DIR
  rm -rf $FZF_TMP_DIR
  echo "Done"
}

clone_repo() {
  plugin_name=$1
  owner=$2
  repo=$3
  rev=$4
  parent_dir=$5

  url=https://github.com/${owner}/${repo}
  target_dir="${parent_dir}/${plugin_name}"

  echo "Cloning ${url} (revision: ${rev})"

  if [ -d ${target_dir} ]; then
    rm -rf ${target_dir}
  fi

  git clone --quiet ${url} ${target_dir} 2>/dev/null
  git --work-tree=${target_dir} --git-dir=${target_dir}/.git checkout --quiet ${rev}
}

clone_all_repos() {
  plugin_sources_json=$1
  parent_dir=$2

  cat $plugin_sources_json | jaq -r 'to_entries[] | "\(.key) \(.value | .owner) \(.value | .repo) \(.value | .rev)"' | while read -r plugin_name owner repo rev
  do
    clone_repo $plugin_name $owner $repo $rev $parent_dir
  done
}

download_plugins() {
  plugin_sources_json=$1
  parent_dir=$2

  case ${parent_dir} in
    (*".nix-profile"*)
      echo "Plugins seem to be already managed by Nix, aborting"
      return
      ;;
  esac

  if [ ! -d $parent_dir ]; then mkdir -p $parent_dir; fi
  clone_all_repos ${plugin_sources_json} ${parent_dir}
}

generate_nvim_doc() {
  parent_dir=$1
  plugin_name=$2
  readme="${3:-README.md}"

  plugin_dir=${parent_dir}/${plugin_name}

  doc_dir="${plugin_dir}/doc"
  readme_file="${plugin_dir}/${readme}"

  if [ -d ${doc_dir} ]; then
    nvim --headless -u NONE -i NONE -n -c "helptags ${doc_dir}" -c "quit"
  elif [ -f ${readme_file} ]; then
    echo "No docs available for ${plugin_name}, using ${readme}"
    # Force filetype to markdown since nvim sets filetype=help when opening a file through :help
    echo '<!-- vim: set ft=markdown: -->' >> ${readme_file}
    mkdir -p ${doc_dir}
    cp ${readme_file} ${doc_dir}
    echo -e "${plugin_name}.${readme}\t${readme}\t/# " >> ${doc_dir}/tags
  else
    echo "No docs available for ${plugin_name}"
  fi
}

download_zsh_plugins() {
  echo "Downloading ZSH plugins"
  download_plugins "$DOTFILES/scripts/plugins-sources/zsh.json" $ZSH_PLUGINS_DIR
  echo "Done"
}

download_nvim_plugins() {
  echo "Downloading Neovim plugins"
  download_plugins "$DOTFILES/scripts/plugins-sources/neovim.json" $NVIM_PLUGINS_DIR
  echo "Done"
}

generate_nvim_doc_for_nvim_plugins() {
  echo "Generating Neovim plugins doc"
  for plugin in $(ls $NVIM_PLUGINS_DIR); do
    generate_nvim_doc $NVIM_PLUGINS_DIR $plugin
  done
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

install_binaries

install_rust
install_rust_built_applications

NVM_DIR="$HOME/.nvm" # stick default
install_node
install_node_applications

install_skim_shell_bindings
install_fzf_shell_bindings

download_zsh_plugins

download_nvim_plugins
generate_nvim_doc_for_nvim_plugins

create_ssh_key
