# FZF

## fzf-lua plugin in Nix

Some binaries are necessary/recommended for the fzf-lua plugin to work properly (`fzf`, `ripgrep`, `detla`, etc.).

The fzf-lua plugin looks up these binaries from the PATH environment variable.

An extreme approach would have been to patch the plugin at build time in nix to replace occurences of those binaries by their full path in the nix store such as ${ripgrep}/bin/rg but that's not easy to maintain.

An alternative would have been to use nix to wrap the resulting `nvim` executable in a script where we set the PATH environment variable to hold only the paths to these required executables.

However since we also want to use those binaries on their own, it just makes sense to install them directly and not as dependencies of nvim.

## fzf-lua plugin

- For the keymap option, the `keymap.builtin` object is for Neovim terminal mode bindings which are local to the fzf-lua buffer, while the `keymap.fzf` is for the bindings passed as an the value to the `--bind` option of the `fzf` command.

- In fzf-lua:
  - a `provider` is a function that generates the content that will be piped through to the `fzf` command 
  - an `action` describes how you process the lines selected by `fzf`. Each action is bound to a key and passed to the `fzf` command through the `--bind` option. Under the hood, this ends up starting a headless `nvim` which connects to local socket of the running `nvim` instance and triggers a rpc function that is registered ahead of time, for example:
  ```
  ...
  --bind alt-t:execute-silent:'/abs/path/to/bin/nvim' -u NONE -l '/abs/path/to/neovim-plugins/fzf-lua/lua/fzf-lua/rpc.lua' 2 nil {+} {q} {n} 
  ...
  ```
  NB: the previewer also uses this mechanism:
  ```
  --preview '/abs/path/to/bin/nvim' -u NONE -l '/abs/path/to/neovim-plugins/fzf-lua/lua/fzf-lua/rpc.lua' 9 nil {} {q} {n}
  ```
  NB: contrast the above with the builtin keymap mappings which end up translating to:
  ```
  --bind alt-d:preview-page-down,ctrl-a:beginning-of-line,alt-e:preview-page-up,ctrl-e:end-of-line,alt-a:toggle-all,alt-p:toggle-preview,ctrl-z:abort,ctrl-u:unix-line-discard,alt-w:toggle-preview-wrap 
  ```

- A lot of providers inherit the default actions `action.files` and `action.buffers` defined in the setup function (these are global defaults). Actions specific to a provider can be defined in each provider configuration (eg. `helptags.action` in the setup function for the helptag provider). Those will be merged with whatever defaults was already defined or inherited from. Checkout `:h fzf-lua-default-options` or the `fzf-lua/defaults.lua` file.

- There are 2 low level functions to bulid a `fzf-lua` menu:
  - `core.fzf_exec(contents, opts)`: which pipes a series of lines to fzf (lines are produce by contents which can be a table of strings or a function), the `fzf` command is then used with properly set `--bind` options to fuzzy select 1 or many lines and perform an action on the selected lines
  - `core.fzf_live(contents, opts)`: which pipes a new series of lines at each keystroke typed. This effectively disables `fzf` fuzzy matching (since lines are selected based on the keystrokes before being sent to `fzf`) but still allows to select lines in `fzf` with `Ctrl-j/k` (comments in the code says this "utilizes fzf's 'change:reload' event")

- Note the difference between `live-*` commands and their counterpart. For instance `fzf.live-grep-project` greps for the new input at each key stroke and pass those results to `fzf`, whereas `fzf.grep_project` sends all files through to `fzf`. Similarly for `lsp_workspace_symbols`, the lsp client sends an empty request to the server and sends those results to `fzf`. Check in `fzf-lua/providers/lsp.lua`:
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

### require('fzf-lua').fzf_exec walk through

- `fzf_exec` does 2 things:
  - it creates a string which corresponds to the command to be launched to produce the lines sent to `fzf`:
  ```lua
  local cmd = shell.stringify_mt(contents, opts) or shell.stringify(contents, opts, nil)
  ```
  - it spawns a process executing that `cmd` and `fzf` with the proper keyboard bindings in a terminal window
  ```lua
  return M.fzf_wrap(cmd, opts, true)
  ```

- `shell.stringify_mt` results in a string that will spawn `nvim` in headless mode to execute the `fzf-lua/spawn.lua` script which basically:
  - deserializes arguments passed to `nvim`:
  ```lua
  local opts = require("fzf-lua.libuv").deserialize(_G.arg[1])
  ```
  - call the `fzf-lua.libuv.spawn_stdio` function which:
  ```lua
  local _, pid = require("fzf-lua.libuv").spawn_stdio(opts)
  ```

- `libuv.spawn_stdio` does the following:
  - if the contents is a lua table or a function, it is directly sent to `stdout` (so basically it just deserialized some `lua` data and optionally executed a `lua` function - function case)
  ```lua
  -- just before the very end of that function
  if type(cmd) ~= "string" then
    local f = fn_transform or function(x) return x end
    local w = function(s) if s then io.stdout:write(f(s) .. EOL) else on_finish(0) end end
    local wn = function(s) if s then return io.stdout:write(f(s)) else on_finish(0) end end
    -- ...
    if type(cmd) == "function" then cmd(w, wn) end
    if type(cmd) == "table" then for _, v in ipairs(cmd) do w(v) end end
    if type(cmd) ~= "string" then on_finish(0) end
    -- ...
  end
  ```
  - if the content is a string, meaning it represents an external binary to run, it will call `libuv.spawn` which will fork another process.

- `libuv.spawn` forks the process using `uv.spawn`. This will in turn create also another coroutine inside the runnning headless `nvim` instance. and register callbacks to split the lines and process the output from that forked process properly before => where does the nvim headless process writes it to is own stdout??

- stringify: creates the --bind part: it creates a function that it registers, and make the --bind value execute nvim fzf-lua/rpc.lua with that id. Guess, fzf apppends the selection as an arg to this command. In fzf-lua/rpc.lua, we create a server (which will serve the selection passed as arguments) and then we rpc the main nvim instance to ask it to run a particular function which will connect to us and pull the data.

- To launch the fzf command (regular `fzf_exec` scenario, not `fzf_live` which is interactive), the plugin uses a `coroutine`. It basically creates a coroutine (inside `fzf_wrap`) which ends up launching a process in the terminal (using `jobstart` with `pty = true` in `fzf_raw`). In the `on_exit` callback to this process there is a `coroutine.resume` which allows to jump back to the post treatment part. 

- Note that `jobstart` spawns an external process via libuv and returns immediately. `libuv` runs an event loop in Neovim’s main thread. It watches the child process, pipes, timers, etc., and posts events back to Neovim. `on_exit` is invoked by Neovim when the event loop detects the child process has exited. The callback runs on the main thread, not in parallel.
