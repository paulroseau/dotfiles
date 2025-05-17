# Nvim smart window navigation

This is a simple plugin which aims at helping you navigate from and out of Neovim windows when `neovim` runs inside a terminal with pane splitting capabilities such as `wezterm` or `tmux`.

## Requirements

TODO explain the idea and dependencies

## Autogroups

TODO

## Commands

This plugin creates the `NvimTmuxWincmd` which wraps around the builtin neovim `wincmd` and allows you to move out of the tmux pane where `neovim` is running when there is no adjacent window to the current `neovim` window but there is an adjacent `tmux` pane.
