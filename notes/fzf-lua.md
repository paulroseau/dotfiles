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
  ```lua
  local cmd = shell.stringify_mt(contents, opts) or shell.stringify(contents, opts, nil)
  return M.fzf_wrap(cmd, opts, true)
  ```
  - it creates a string which corresponds to the command to be launched to produce the lines sent to `fzf`:
  - it spawns a process executing that `cmd` and `fzf` with the proper keyboard bindings in a terminal window

#### 1. stringify phase (shell.stringify_mt variant)

- `shell.stringify_mt` results in a string that will spawn `nvim` in headless mode to execute the `fzf-lua/spawn.lua` script with the `opts` serialized and passed as `args` (done in the `shell.wrap_spawn_stdio` function):
  ```lua
  for _, k in ipairs({ "contents", "fn_transform", "fn_preprocess", "fn_postprocess" }) do
    if type(opts[k]) == "function" then M.check_upvalue(opts[k], "opts." .. k) end
  end
  local cmd_str = ("%s -u NONE -l %s %s"):format(
    libuv.shellescape(is_win and vim.fs.normalize(nvim_bin) or nvim_bin),
    libuv.shellescape(vim.fn.fnamemodify(is_win and vim.fs.normalize(__FILE__) or __FILE__, ":h") .. "/spawn.lua"),
    libuv.shellescape((libuv.serialize(opts, true))))
  return cmd_str
  ```

- `spawn.lua` basically:
  ```lua
  local opts = require("fzf-lua.libuv").deserialize(_G.arg[1])
  local _, pid = require("fzf-lua.libuv").spawn_stdio(opts)
  ```
  - deserializes arguments passed to `nvim`
  - calls the `fzf-lua.libuv.spawn_stdio` function which

- `libuv.spawn_stdio` does the following:
  ```lua
  -- cf. end of that function

  -- table or function case
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

  -- external command (ie. string) with no transform / postprocess case
  if not fn_transform and not fn_postprocess then posix_exec(cmd) end

  -- external command (ie. string) with transform / postprocess case
  return M.spawn({
      cwd = opts.cwd,
      cmd = cmd,
      cb_finish = on_finish,
      cb_write = on_write,
      cb_err = on_err,
      process1 = opts.process1,
      profiler = opts.profiler,
      EOL = EOL,
    },
    fn_transform and function(x)
      return fn_transform(x, opts)
    end)
  ```
  - if the content is a lua table or a function, it is directly sent to `stdout` (so basically `spawn.lua` just deserialized some `lua` data or function passed as CLI arguments to the headless `nvim` and then we just output those properly transformed to stdout)
  - if the content is a string, meaning it represents an external binary to run we have 2 subcases:
    1. if there is no transform or postprocess, we simply fork the process using the `execl` syscall C wrapper through the `shell.posix_exec` function: 
    ```lua
    local posix_exec = function(cmd)
      if type(cmd) ~= "string" or _is_win or not pcall(require, "ffi") then return end
      require("ffi").cdef([[int execl(const char *, const char *, ...);]]) -- define the address to jump to
      require("ffi").C.execl("/bin/sh", "sh", "-c", cmd, nil) -- push values from the Lua State to the stack and call
    end
    ```
    2. if there are transform of lines or postprocessing then we call `libuv.spawn` which will fork another process with callbacks registered. Note out in particular that `cb_write` is set to the `on_write` function which also ends up writing its argument to `stdout` (else part unless we specify a name to `stdout`):
    ```lua
      local on_write = opts.on_write or function(data, cb)
        if stdout then
          pipe_write(stdout, data, cb)
        else
          -- on success: rc=true, err=nil
          -- on failure: rc=nil, err="Broken pipe"
          -- cb with an err ends the process
          local rc, err = io.stdout:write(data)
          if not rc then
            stderr_write(("io.stdout:write error: %s" .. EOL):format(err))
            cb(err or true)
          else
            cb(nil)
          end
        end
      end
    ```
    in other terms this function is passed down such that we can add a callback to the forked process in order to write to the stdout of the `nvim` headless process that is executing `spawn.lua`

##### Details on fzf-lua.spawn.spawn.lua in that context

- `libuv.spawn` forks the process using `uv.spawn`. This will in turn create another `coroutine` inside the runnning headless `nvim` instance, which will:
  ```lua
  M.spawn = function(opts, fn_transform, fn_done)
    -- ...
    local output_pipe = assert(uv.new_pipe(false))
    local error_pipe = assert(uv.new_pipe(false))

    -- create the shell command to spawn, and the finish function to call on_exit
    local shell = -- ...

    -- spawn the shell command
    handle, pid = uv.spawn(shell, {
      args = args,
      stdio = { nil, output_pipe, error_pipe },
      cwd = opts.cwd,
      ---@diagnostic disable-next-line: assign-type-mismatch
      env = -- ...
      verbatim = _is_win,
    }, function(code, signal)
      if can_finish() or code ~= 0 then
        -- Do not call `:read_stop` or `:close` here as we may have data
        -- reads outstanding on slower Windows machines (#1521), only call
        -- `finish` if all our `uv.write` calls are completed and the pipe
        -- is no longer active (i.e. no more read cb's expected)
        finish(code, signal, "[on_exit]", pid)
      end
      handle:close()
    end)

    -- define read call back
    local read_cb = function(err, data)
    end

    -- register call back on the pipes
    if not handle then
      err_cb(nil, pid .. EOL)
      err_cb(pid, nil)
    else
      output_pipe:read_start(read_cb)
      error_pipe:read_start(err_cb)
    end
    ```
  - create a `stdout` and `stderr` unix sockets (lua pipes)
  - spawn the string command with `stdout`, `stderr` attached to the previously created sockets
  - creates a `read_cb` (which in turn calls `process_data` which calls `write_cb` which calls `opts.write_cb` which is set in `spawn_stdio` to write to `stdout`)

- NB: The implem has the option to use a queue to push work to do in the `read_cb` function then the current coroutine yields when the queue is empty and it will be resumed when the `uv.loop` executes the read_cb when data is pushed to the pipe by the forked process. This basically allows to return to the while loop at the bottom of the function, which will process whatever is available or yield control again to the main coroutine (which runs the uv.loop) to do other work.
  ```lua
  local read_cb = function(err, data)
    if err then
      -- ...
    end
    if not data then
      -- ...
    end
    if opts.use_queue then
      if data then queue:push(data) end
      coroutine.resume(co)
    else
      process = function ()
        -- ...
      end
      if vim.in_fast_event() then vim.schedule(process) else process() end
    end
  end
  -- ...
  if opts.use_queue then
    while not (output_pipe:is_closing() and queue:empty()) do
      if queue:empty() then
        coroutine.yield()
      else
        process_data(queue:pop())
      end
    end
    process_data(nil)
  end
  ``` 
However it seems that `opts.use_queue` is set to `false` when running in headless mode so this is not relevant in the context of creating that producer command.

- NB: Under the hood `coroutine.create()` results in creating another `lua_State` (basically another stack basically plus a Lua execution pointer, cf. `lua_State *lua_newthread (lua_State *L)`) that you jump to within the same C thread using `coroutine.resume(co)` (cf. `int lua_resume (lua_State *L, int narg)`). When calling `yield` you go back to the `lua_State` that created the coroutine and resume execution there. Watch out the lua doc refers to "thread" as a lua thread which basically are equivalent to a `lua_State`. However the whole lua code, even though it can contain several coroutines and hence several `lua_State`, is all executed in one single `pthread`. To do proper multi-threading `nvim` relies on `uv` which creates an event loop which can fork processes, create unix sockets (confusingly called `pipe` in `uv`) and return a handle that gets executed when the OS signals the process is complete to `uv` (more details on in `uv` notes on how this is achieve through an `epoll` based event loop).

#### 1. stringify phase (shell.stringify variant)

- The alternative to using `stringify_mt` is `stringify` which uses a different strategy. It registers a callback into that main instance, and makes the resulting string command start a headless `nvim` instance that will execute the `rpc.lua` file with the id of the callback as a parameter. This is all done inside `shell.pipe_wrap_fn` function which `shell.stringify` calls:
    ```lua
    function M.pipe_wrap_fn(fn, fzf_field_index, debug)
      fzf_field_index = fzf_field_index or "{+}"

      local receiving_function = function(pipe_path, ...)
        local pipe = uv.new_pipe(false)
        -- ...
        uv.pipe_connect(pipe, pipe_path, function(err)
          if err then
            error(string.format("pipe_connect(%s) failed with error: %s", pipe_path, err))
          else
            vim.schedule(function()
              fn(pipe, unpack(args))
            end)
          end
        end)
      end

      local id = M.register_func(receiving_function)

      -- all args after `-l` will be in `_G.args`
      local action_cmd = ("%s -u NONE -l %s %s %s %s"):format(
        libuv.shellescape(path.normalize(nvim_bin)),
        libuv.shellescape(path.normalize(path.join { vim.g.fzf_lua_directory, "rpc.lua" })),
        id,
        tostring(debug),
        fzf_field_index)

      return action_cmd, id
    end
    ```

- `shell.stringify` create complex function that is passed as the `fn` arguments and handles all the cases where contents can be either a table, a lua function or string (external command). In the case of an external command it will be spawned asynchronously through `fzf-lua.libuv.spawn` (which is an async version of `fzf-lua.spawn` described above) from the main nvim instance when the registered rpc endpoint gets triggered. 

- The reason why this is so complex is because `shell.stringify` is also used to by `shell.stringify_cmd` which is the mechanism used to bind keystrokes inside `fzf` (cf. `--bind` above) and hence should handle all the cases. In the context of producing the content to "pipe" to `fzf` though, it seems that in most cases `stringify_mt` is used.

#### 2. fzf-lua.core.fzf_wrap phase (until we fork the fzf process and hit the first and only yield)

- `fzf-lua.core.fzf_wrap` runs `fzf-lua.core.fzf` inside a coroutine. It does so through `coroutine.wrap`, meaning it a function that creates a coroutine and calls `coroutine.resume`. In this case the function returned by `coroutine.wrap` is called immediately:
```lua
M.fzf_wrap = function(cmd, opts, convert_actions)
  -- ...
  local _co, fn_selected
  coroutine.wrap(function()
    _co = coroutine.running()
    -- xpcall to get full traceback https://www.lua.org/pil/8.5.html
    local _, err = (jit and xpcall or require("fzf-lua.lib.copcall").xpcall)(function()
      -- ...
      local selected, exit_code = M.fzf(cmd, opts)
      if not tonumber(exit_code) then return end
      fn_selected = opts.fn_selected or actions.act
      -- ...
      fn_selected(selected, opts)
    end, debug.traceback)

    if err then
      -- ...
      utils.error("fn_selected threw an error: " .. err)
    end
  end)()
  return _co, cmd, opts
end
```

- `fzf-lua.core.fzf` sets all the options passed in arguments (special hidden options are set if the command is triggered from fzf-lua already such as `fzf-lua.resume`, etc.), creates a window of the right size, creates the shell `fzf` command line that needs to be executed and passes to `fzf-lua.fzf.raw_fzf`:
```lua

M.fzf = function(contents, opts)
  -- ...
  local selected, exit_code = fzf.raw_fzf(opts.is_live and utils.shell_nop() or contents,
    M.build_fzf_cli(opts),
    {
      fzf_bin = opts.fzf_bin,
      cwd = opts.cwd,
      pipe_cmd = opts.pipe_cmd,
      silent_fail = opts.silent_fail,
      is_fzf_tmux = opts._is_fzf_tmux,
      debug = opts.debug,
      RIPGREP_CONFIG_PATH = opts.RIPGREP_CONFIG_PATH,
    })

  -- start of the second part of the function

  -- raw_fzf will yield the current coroutine created in fzf_wrap and uv will resume it once the forked process is complete, effectively jumping back here 
  -- we'll detail that post processing in part 3 to explain the code as it gets called in chronological order
```

- `fzf-lua.fzf.raw_fzf` ends up forking the actual shell process which will run `fzf` with the `FZF_DEFAULT_COMMAND` set to the "producer" command (a headless nvim process with the proper arguments resulting from the `stringify_mt` or `stringify` step). Hence `fzf` will be responsible to create the producer process and make sure it cleans it up. To start that shell process, `fzf-lua.fzf.raw_fzf` uses `vim.fn.jobstart` with `opts.term = true`. Under the hood `jobstart` binds into C code that will eventually call the C uv_spawn function, just like `vim.uv.spawn` does. Setting the `opts.term` option to `true` (which implies `opts.pty` to be true) will create a `pty` and attach it to the current buffer with stdin/stdout of the process attached to that `pty` stdout/stdin.
```lua
-- simplified and reordered a bit
function M.raw_fzf(contents, fzf_cli_args, opts)
  -- ...
  -- create the fzf command
  local cmd = { opts.fzf_bin or "fzf" }
  utils.tbl_join(cmd, fzf_cli_args or {})
  -- pipe the output to a temporary file (outputtmpname is created before)
  table.insert(cmd, ">")
  table.insert(cmd, libuv.shellescape(outputtmpname))

  -- FZF_DEFAULT_COMMAND set to the 'producer' command
  local FZF_DEFAULT_COMMAND = (function()
    -- some checks about contents, plus appending redirect if required
    return contents
  end)()
  -- ...
  -- Make sure we are running inside a coroutine so we can yield after spawning and be resumed in the process handle (uv will resume us)
  if not coroutine.running() then
    error("[Fzf-lua] function must be called inside a coroutine.")
  end
  local co = coroutine.running()
  
  -- utils.termopen basically maps to vim.fn.jobstart(cmd, { term = true })
  local jobstart = opts.is_fzf_tmux and vim.fn.jobstart or utils.termopen
  -- build the whole shell command
  local shell_cmd = utils.__IS_WINDOWS
      and { "cmd.exe", "/d", "/e:off", "/f:off", "/v:off", "/c" }
      or { "sh", "-c" }
  -- if we don't want to rely on 'FZF_DEFAULT_COMMAND', we pipe the 'producer' command to fzf and reset 'FZF_DEFAULT_COMMAND' to nil
  if opts.pipe_cmd then
    if FZF_DEFAULT_COMMAND then
      table.insert(cmd, 1, string.format("(%s) | ", FZF_DEFAULT_COMMAND))
      FZF_DEFAULT_COMMAND = nil
    end
    table.insert(shell_cmd, table.concat(cmd, " "))
  elseif utils.__IS_WINDOWS then
    utils.tbl_join(shell_cmd, cmd)
  else
    table.insert(shell_cmd, table.concat(cmd, " "))
  end
  -- spawn the process and attach a callback to uv's handle via on_exit
  jobstart(shell_cmd, {
    cwd = opts.cwd,
    pty = true,
    env = {
      ["SHELL"] = shell_cmd[1],
      -- ...
      ["FZF_DEFAULT_COMMAND"] = FZF_DEFAULT_COMMAND,
      ["SKIM_DEFAULT_COMMAND"] = FZF_DEFAULT_COMMAND,
      ["FZF_LUA_SERVER"] = vim.g.fzf_lua_server,
      -- sk --tmux didn't pass all environemnt variable (https://github.com/skim-rs/skim/issues/732)
      ["SKIM_FZF_LUA_SERVER"] = vim.g.fzf_lua_server,
      ["VIMRUNTIME"] = vim.env.VIMRUNTIME,
      ["FZF_DEFAULT_OPTS"] = (function()
        -- ...
      end)(),
       -- ...
    },
    on_exit = function(_, rc, _)
      -- this part is executed by uv as a callback once it can read from the signalfd created for the fork process (cf. notes on uv.md)
      -- read the content from the temporary file, delete it and resume the coroutine
      local output = {}
      local f = io.open(outputtmpname)
      if f then
        output = vim.split(f:read("*a"), printEOL)
        output[#output] = nil
        f:close()
      end
      -- ...
      vim.fn.delete(outputtmpname)
      -- ...
      -- resume the coroutine after the call to yield lower
      coroutine.resume(co, output, rc)
    end
  })

  -- ...
  -- suspend the current coroutine, uv will resume us here so we can jump back to core.fzf function at
  -- local selected, exit_code = fzf.raw_fzf()
  -- this makes the call effectively non blocking
  return coroutine.yield()
```

- NB: The coroutine we trigger `jobstart` from was initially created in ` fzf_wrap` through `coroutine.wrap` which returned a function that we called immediately:
```lua
M.fzf_wrap = function(cmd, opts, convert_actions)
  -- ...
  coroutine.wrap(function()
    
    local _, err = xpcall(function()
      -- ...
      local selected, exit_code = M.fzf(cmd, opts)
      if not tonumber(exit_code) then return end
      fn_selected = opts.fn_selected or actions.act
      -- ...
      fn_selected(selected, opts)
    end, debug.traceback)
    if err then
      -- ...
    end
  end)()
```
Hence after this call we will hit the first and only `yield` inside `fzf -> raw_fzf`, and we will be resumed not by recalling that wrapped function but by having `uv` directly resume us through the `co` reference that we set in the jobstart callback. Hence I wonder if a call to `coroutine.wrap` was really beneficial here (that's a detail)

#### 3. post processing once the forked process is complete and uv resumes execution of core.fzf

- NB: When the command requires to relaunch fzf on an updated list (eg. we were selecting buffers and we decide to delete a buffer with `ctrl-x` inside `fzf`), the reloading is provided by `fzf`:
```
fzf \
  --highlight-line \
  --multi \
  --print-query \
  --header-lines 1 \
  ...
  --bind ctrl-x:unbind(ctrl-x)+execute-silent('/nix/store/zgyxsvzpnh4lrmr71q224wvbm58nhh2r-neovim-unwrapped-0.11.4/bin/nvim' -u NONE -l '/Users/polo/.nix-profile/share/neovim-plugins/fzf-lua/lua/fzf-lua/rpc.lua' 766 nil {+} {q} {n})+reload('/nix/store/zgyxsvzpnh4lrmr71q224wvbm58nhh2r-neovim-unwrapped-0.11.4/bin/nvim' -u NONE -l '/Users/polo/.nix-profile/share/neovim-plugins/fzf-lua/lua/fzf-lua/rpc.lua' 765 nil ) \
  ...
  --bind=load:+rebind(ctrl-x) \
```


--- CLEAN THIS
- stringify: creates the --bind part: it creates a function that it registers, and make the --bind value execute nvim fzf-lua/rpc.lua with that id. Guess, fzf apppends the selection as an arg to this command. In fzf-lua/rpc.lua, we create a server (which will serve the selection passed as arguments) and then we rpc the main nvim instance to ask it to run a particular function which will connect to us and pull the data.

- To launch the fzf command (regular `fzf_exec` scenario, not `fzf_live` which is interactive), the plugin uses a `coroutine`. It basically creates a coroutine (inside `fzf_wrap`) which ends up launching a process in the terminal (using `jobstart` with `pty = true` in `fzf_raw`). In the `on_exit` callback to this process there is a `coroutine.resume` which allows to jump back to the post treatment part. 

- Note that `jobstart` spawns an external process via libuv and returns immediately. `libuv` runs an event loop in Neovim’s main thread. It watches the child process, pipes, timers, etc., and posts events back to Neovim. `on_exit` is invoked by Neovim when the event loop detects the child process has exited. The callback runs on the main thread, not in parallel.
