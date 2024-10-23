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

## Updates 

### Update nixpkgs

```sh
# List channels
nix-channel --list

# List current channels
nix-channel --list-generations

# Update the nixpkgs channel
nix-channel --update nixpkgs
```

You can then reinstall packages based of the latest version of `<nixpkgs>`:
```sh
# Example reinstall all my base packages
nix-env --install --file nix/default.nix -A myPkgs.base
```

### Update packages with niv

```sh
# Add
niv -s ./nix/neovim-plugins/plugins/sources.json add hrsh7th/cmp-cmdline

# Update to a particular version
niv -s ./nix/neovim-plugins/plugins/sources.json update nvim-treesitter -r v0.9.1

niv -s ./nix/sources.json update neovim -r v0.10.2
```

Then you need to reinstall the package with `nix`:
```sh
nix-env --install --file nix/default.nix -A '<package>'
```

## Deletions

```sh
# Delete a package (creates a new environment without the package)
nix-env --uninstall --file nix/default -A '<package>'

# List all nix environment generations
nix-env --list-generations

# Switch to a particular nix environment
nix-env --switch-generation ${generation_number}

# Delete old environment generations
nix-env --delete-generations 69 70

# Roll back to the previous generation (if you broke anything - equivalent to `nix-env --switch-generation <previous-generation>`
nix-env --rollback

# Garbage collect unused packages
nix-store --gc
nix-collect-garbage

# Utility to delete old generations and collect garbage
nix-collect-garbage --delete-old
nix-collect-garbage --delete-older-than 2d
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
