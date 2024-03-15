# My dotfiles

## Install

```sh
./install.sh
```

## Update dependencies with niv

```sh
# Add
niv -s ./nix/neovim/plugins/sources.json add hrsh7th/cmp-cmdline

# Update to a particular version
niv -s ./nix/neovim/plugins/sources.json update nvim-treesitter -r v0.9.1
```
