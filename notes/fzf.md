# FZF

## fzf-lua plugin

- For the keymap option, the `keymap.builtin` object is for Neovim terminal mode bindings which are local to the fzf-lua buffer, while the `keymap.fzf` is for the bindings passed as an the value to the `--bind` option of the `fzf` command.

- In fzf-lua, a `provider` is whatever is passed to fzf command, an `action` is whatever action you can do on the selected item(s).A lot of providers inherit the default actions `action.files` and `action.buffers` defined in the setup function (these are global defaults). Actions specific to a provider can be defined in each provider configuration (eg. `helptags.action` in the setup function for the helptag provider). Those will be merged with whatever defaults was already defined or inherited from. Checkout `:h fzf-lua-default-options` or the `fzf-lua/defaults.lua` file.
