# Nvim-Tmux

This is a simple plugin which aims at helping you navigate from and out of
neovim windows when `neovim` runs inside `tmux`.

## Requirements

TODO explain the vim_option mechanism.

## Autogroups

This plugin creates the `NvimTmux` augroup.

## Commands

This plugin creates the `NvimTmuxWincmd` which wraps around the builtin neovim
`wincmd` and allows you to move out of the tmux pane where `neovim` is running
when there is no adjacent window to the current `neovim` window but there is an
adjacent `tmux` pane.

## Credits
