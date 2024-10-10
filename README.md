# My dotfiles

## Install

### Pre-requisite

You need to install the [nix package manager](https://nixos.org/download/).

### Install from scratch

```sh
./install.sh
```

### Install individual packages

You can install any package with:
```sh
nix-env --install -A 'some-package'
```

NB: some packages are overriden in this repository (pinned to a particular version for example).

There is a `myPkgs` attribute which gathers "bundles" of packages to install multiple tools more easily. For example:
```sh
# install neovim and its plugins
nix-env --install --file nix/default.nix -A 'myPkgs.neovim'

# install the required development tools for a rust project
nix-env --install --file nix/default.nix -A 'myPkgs.development.rust'

# install all the basic tools on a local workstation (alacritty, zsh & plugins, neovim & plugins, etc.)
nix-env --install --file nix/default.nix 'myPkgs.local'
```

## Update dependencies with niv

```sh
# Add
niv -s ./nix/neovim-plugins/plugins/sources.json add hrsh7th/cmp-cmdline

# Update to a particular version
niv -s ./nix/neovim-plugins/plugins/sources.json update nvim-treesitter -r v0.9.1
```

## Tips

### Tmux

Remember that you can copy/paste the content of a tmux pane with:
```
# copy from the top of the visible part of the pane
capture-pane -S

# copy from the begining of the pane
capture-pane -S -

# paste
paste-buffer
```

More details through `man tmux`.
