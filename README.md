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
nix-env --file '<nixpkgs>' --install --attr 'some-package'
# or
nix-env -f '<nixpkgs>' -iA 'some-package'
```

NB: some packages are overriden in this repository (pinned to a particular version for example).

There is a `myPkgs` attribute which gathers "bundles" of packages to install multiple tools more easily. For example:
```sh
# install neovim and its plugins
nix-env -f '<nixpkgs>' -iA 'myPkgs.neovim'

# install the required development tools for a rust project
nix-env -f '<nixpkgs>' -iA 'myPkgs.development.rust'

# install all the basic tools on a local workstation (wezterm, zsh & plugins, neovim & plugins, etc.)
nix-env -f '<nixpkgs>' -iA 'myPkgs.local'
```

### Install new neovim plugins

```sh
NVIM_PLUGINS_SOURCES="$HOME/.config/nixpkgs/overlays/10-my-packages/packages/neovim-plugins/plugins/sources.json"
# Add the plugin to the list of plugins with niv
niv -s $NVIM_PLUGINS_SOURCES add hrsh7th/cmp-cmdline

# Install it 
nix-env -f '<nixpkgs>' -iA 'neovim-plugins'
# or (to reinstal neovim if necessary)
nix-env -f '<nixpkgs>' -iA 'myPkgs.neovim'
```

### Add Treesitter support for new languages

```sh
TREESITTER_PARSERS_SOURCES="$HOME/.config/nixpkgs/overlays/10-my-packages/packages/neovim-plugins/tree-sitter-parsers/sources.json"
# Add a tree-sitter parser with a name with -n option and at a particular version
niv -s $TREESITTER_PARSERS_SOURCES add -n lua tree-sitter-grammars/tree-sitter-lua -r v0.2.0
# Install it
nix-env -f '<nixpkgs>' -iA 'myPkgs.neovim'
```

Remark: the `-n` option is important, because by convention we use the keys in `tree-sitter-parsers/sources.json` as the name of the built parser, and `nvim` resolves tree-sitter parsers expecting their name to match the filetype. For example, with the line above it will be `lua.so` (without the `-n` option it would have been `tree-sitter-lua.so` which would cause the parser to not be found by `nvim`).

Remark: `nvim` does come with a few tree-sitter parsers built-in (in the `../lib/nvim/parser` directory - `../lib/nvim` is part of the runtimepath by default), however those sometimes ship with errors, so we override them by downloading our own and setting them in the `nvim-treesitter` plugin `parser` directory. The `nvim-treesitter` plugin searches parsers in that directory first.

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
nix-env -f '<nixpkgs>' -iA 'myPkgs.base'
```

### Update packages with niv

```sh
BINARY_SOURCES="$HOME/.config/nixpkgs/overlays/10-my-packages/sources.json"
NVIM_PLUGINS_SOURCES="$HOME/.config/nixpkgs/overlays/10-my-packages/packages/neovim-plugins/plugins/sources.json"
TREESITTER_PARSERS_SOURCES="$HOME/.config/nixpkgs/overlays/10-my-packages/packages/neovim-plugins/tree-sitter-parsers/sources.json"

# Add
niv -s $NVIM_PLUGINS_SOURCES add hrsh7th/cmp-cmdline

# Add a tree-sitter parser with a name with -n option and at a particular version
niv -s $TREESITTER_PARSERS_SOURCES add -n lua tree-sitter-grammars/tree-sitter-lua -r v0.2.0

# Update to a particular version
niv -s $NVIM_PLUGINS_SOURCES update nvim-treesitter -r v0.9.1

niv -s $BINARY_SOURCES  update neovim -r v0.10.2
```

Then you need to reinstall the package with `nix`:
```sh
nix-env -f '<nixpkgs>' -iA '<package>'
```

## Deletions

```sh
# Delete a package (creates a new environment without the package)
nix-env --file '<nixpkgs>' --uninstall '<package>'
# or
nix-env -f '<nixpkgs>' -e '<package>'

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
