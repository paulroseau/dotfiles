# FZF

## fzf-lua plugin in Nix

Some binaries are necessary/recommended for the fzf-lua plugin to work properly (`fzf`, `ripgrep`, `detla`, etc.).

The fzf-lua plugin looks up these binaries from the PATH environment variable.

An extreme approach would have been to patch the plugin at build time in nix to replace occurences of those binaries by their full path in the nix store such as ${ripgrep}/bin/rg but that's not easy to maintain.

An alternative would have been to use nix to wrap the resulting `nvim` executable in a script where we set the PATH environment variable to hold only the paths to these required executables.

However since we also want to use those binaries on their own, it just makes sense to install them directly and not as dependencies of nvim.

## fzf-lua plugin

- For the keymap option, the `keymap.builtin` object is for Neovim terminal mode bindings which are local to the fzf-lua buffer, while the `keymap.fzf` is for the bindings passed as an the value to the `--bind` option of the `fzf` command.

- In fzf-lua, a `provider` is whatever is passed to fzf command, an `action` is whatever action you can do on the selected item(s).A lot of providers inherit the default actions `action.files` and `action.buffers` defined in the setup function (these are global defaults). Actions specific to a provider can be defined in each provider configuration (eg. `helptags.action` in the setup function for the helptag provider). Those will be merged with whatever defaults was already defined or inherited from. Checkout `:h fzf-lua-default-options` or the `fzf-lua/defaults.lua` file.

- Note the difference between `live-*` commands and their counterpart. For instance `fzf.live-grep-project` greps for the new input at each key stroke and passt those results to `fzf`, whereas `fzf.grep_project` sends all files through to `fzf`. Similarly for `lsp_workspace_symbols`, the lsp client sends an empty request to the server and sends those results to `fzf`. Check in `fzf-lua/providers/lsp.lua`:
```lua
M.workspace_symbols = function(opts)
  ...
  opts.lsp_params = { query = opts.lsp_query or "" }
  ...
  opts = gen_lsp_contents(opts)
  if not opts.__contents then
    core.__CTX = nil
    return
  end
  ...
  return core.fzf_exec(opts.__contents, opts)
end
```

- Even though the LSP spec instructs to return all the symbols for the workspace, for performance reasons language servers return either nothing, or a limit of characters. In the `lua-ls` case, only ~1000 results are returned, cf. implementation in `script/core/workspace-symbol.lua`:
```lua
local function searchWords(key, suri, results)
    for uri in files.eachFile(suri) do
        searchFile(uri, key, results)
        if #results > 1000 then
            break
        end
        await.delay()
    end
end
```

- This is why it is preferable to start with a simple subpattern in `lsp_live_workspace_symbols` and then switch with `Ctrl-g` to fuzzy find inside those first results

- In terms of key mappings, some are set by passing them as fzf options to act on the results once fzf is running (for example, using `alt-a` to select all the results) while others are set on the fzf-lua window as native nvim mappings to affect the layout (like `toggle-preview`, etc.)

- To launch the fzf command, the plugin uses uv under the hood through `uv.spawn` (checkout `./fzf-lua/libuv.lua` `M.spawn()` method)
