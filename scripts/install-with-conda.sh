#!/bin/bash

# clone this repository
export DOTFILES=$HOME/.dotfiles
git clone https://github.com/paulroseau/dotfiles.git $DOTFILES

# install miniforge
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

# install conda in $HOME/conda
MINIFORGE_HOME="${HOME}/.conda-local"
bash Miniforge3-$(uname)-$(uname -m).sh -p $MINIFORGE_HOME -b

# Use the conda you just installed to pull binaries
PATH="$MINIFORGE_HOME/bin:$PATH"
conda init
source $HOME/.bashrc
conda env create -f $DOTFILES/scripts/conda-local-environment.yaml

source_dir="${MINIFORGE_HOME}/envs/local"
target_dir="${HOME}/.local"

function link_binaries {
  source_sub_dir=$1
  echo "Creating $target_dir/$source_sub_dir/ sub-directory"
  mkdir -p $target_dir/$source_sub_dir

  for a in $(ls $source_dir/$source_sub_dir)
  do
    echo "Linking $source_dir/$source_sub_dir/$a -> $target_dir/$source_sub_dir/$a"
    ln -s $source_dir/$source_sub_dir/$a $target_dir/$source_sub_dir/$a
  done
}

# copying binaries
echo "Linking binaries ..."
link_binaries bin
echo "Linking binaries ... DONE"

if [ -f $HOME/.zshrc ]; then rm $HOME/.zshrc ; fi
ln -s $HOME/.dotfiles/configs/zsh/dot-zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/configs/tmux/dot-tmux.conf $HOME/.tmux.conf
ln -s $HOME/.dotfiles/configs/nvim/dot-config/nvim $HOME/.config/
ln -s $HOME/.dotfiles/configs/starship/dot-config/starship.toml $HOME/.config/
ln -s $HOME/.dotfiles/configs/git/dot-gitconfig $HOME/.gitconfig
ln -s $HOME/.dotfiles/configs/git/dot-config/git/ $HOME/.config/

# Install nvim and zsh plugins (issue with ssl certificate chain)
PATH=$HOME/.local/bin:$PATH
$HOME/.dotfiles/scripts/get-plugins.sh

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$HOME/.dotfiles/scripts/get-binaries-cargo.sh

# Create ssh key
ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -N ""
echo "Copy the following to Gitlab"
/bin/cat $HOME/.ssh/id_rsa.pub

echo 'if [ -f $HOME/.local/bin/zsh ]; then exec $HOME/.local/bin/zsh --login ; fi' > $HOME/.bashrc
