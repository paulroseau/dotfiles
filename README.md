# My dotfiles

## Install

### Pre-requisite

You need to install the [nix package manager](https://nixos.org/download/).

### Install from scratch

```sh
./install.sh
```

### Install individual packages

You can install any package from `nixpkgs` pinned at the version specified in `./sources.json` with:
```sh
nix --install --file nix/default.nix -A 'some-package'
```

NB: some packages are overriden in this repository (pinned to a particular version for example).

There is a `myPkgs` attribute which gathers "bundles" of packages to install multiple tools more easily. For example:
```sh
# install neovim and its plugins
nix --install --file nix/default.nix -A 'myPkgs.neovim'

# install the required development tools for a rust project
nix --install --file nix/default.nix -A 'myPkgs.development.rust'

# install all the basic tools on a local workstation (alacritty, zsh & plugins, neovim & plugins, etc.)
nix --install --file nix/default.nix -A 'myPkgs.local'
```

## Update dependencies with niv

```sh
# Add
niv -s ./nix/neovim/plugins/sources.json add hrsh7th/cmp-cmdline

# Update to a particular version
niv -s ./nix/neovim/plugins/sources.json update nvim-treesitter -r v0.9.1
```
