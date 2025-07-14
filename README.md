# My dotfiles

## Install

### Pre-requisite

You need to install the [nix package manager](https://nixos.org/download/).

### Install from scratch

```sh
nix-shell -p curl bash --command "curl -sSL https://raw.githubusercontent.com/paulroseau/dotfiles/refs/heads/main/install.sh | bash"
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

### Install new neovim plugins

```sh
# Add the plugin to the list of plugins with niv
niv -s ./nix/packages/neovim-plugins/plugins/sources.json add hrsh7th/cmp-cmdline

# Install it 
nix-env --install --file nix/default.nix -A 'neovim-plugins'
# or (to reinstal neovim if necessary)
nix-env --install --file nix/default.nix -A 'myPkgs.neovim'
```

### Add Treesitter support for new languages

```sh
# Add a tree-sitter parser with a name with -n option and at a particular version
niv -s nix/packages/neovim-plugins/tree-sitter-parsers/sources.json add -n lua tree-sitter-grammars/tree-sitter-lua -r v0.2.0

# Install it
nix-env --install --file nix/default.nix -A 'myPkgs.neovim'
```

Remark: the `-n` option is important, because by convention use the keys in `tree-sitter-parsers/sources.json` as the name of the built parser, and `nvim` resolves tree-sitter parsers expecting their name to match the filetype. For example, with the line above it will be `lua.so` (without the `-n` option it would have been `tree-sitter-lua.so` which would cause the parser to not be found by neovim).

Remark: `nvim` does come with a few tree-sitter parsers built-in (in the `../lib/nvim/parser` directory - `../lib/nvim` is part of the runtimepath by default), however those sometimes ship with errors, so we override them by downloading our own and setting them in the `nvim-treesitter` plugin `parser` directory. The `nvim-treesitter` plugin searches that directory in priority for parsers.

## Updates 

### Update nixpkgs

```sh
# List channels
nix-channel --list

# List current channels
nix-channel --list-generations

# Update the nixpkgs channel
sudo nix-channel --update nixpkgs
```

You can then reinstall packages based of the latest version of `<nixpkgs>`:
```sh
# Example reinstall all my base packages
nix-env --install --file nix/default.nix -A myPkgs.base
```

### Update packages with niv

```sh
# Add
niv -s ./nix/packages/neovim-plugins/plugins/sources.json add hrsh7th/cmp-cmdline

# Add a tree-sitter parser with a name with -n option and at a particular version
niv -s nix/packages/neovim-plugins/tree-sitter-parsers/sources.json add -n lua tree-sitter-grammars/tree-sitter-lua -r v0.2.0

# Update to a particular version
niv -s ./nix/packages/neovim-plugins/plugins/sources.json update nvim-treesitter -r v0.9.1

niv -s ./nix/sources.json update neovim -r v0.10.2
```

Then you need to reinstall the package with `nix`:
```sh
nix-env --install --file nix/default.nix -A '<package>'
```

## Deletions

```sh
# Delete a package (creates a new environment without the package)
nix-env --uninstall --file nix/default '<package>'

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

# copy from the begining of the pane (beyond the visible part)
capture-pane -S -

# paste
paste-buffer
```

More details through `man tmux`.

## Wezterm

To debug and check user set variables type `Ctrl+Shift+L` to get to the debug console and run:
```lua
wezterm.mux.get_window(0):active_pane():get_user_vars()
```
