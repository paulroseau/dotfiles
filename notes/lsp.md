# LSP

## Diagnostics in Neovim

You can set diagnostic in Neovim to a particular buffer, with the method `vim.diagnostic.set()`. A diagnostic is just an object following a particular structure (cf. `:h diagnostic-structure`).

When diagnostics are set with the above command, the `show` command is called which in turn will invoke the show command on all handlers. By default there are 3 handlers setup: virtual text, signs and underline. Those will modify the appearance of the buffer to display diagnostic in various ways.

Also in the `vim.diagnostic.set()` method, the `DiagnosticChanged` event is fired to allow to register autocommands on it.

Diagnostics are built into Neovim and implemented inside `./lua/runtime/vim/diagnostic.lua`

You can see all the diagnostic set for the current buffer with `lua vim.print(vim.diagnostic.get())`

## Built-in LSP support in Neovim

Neovim comes with the implementation of an LSP client. When launching a client you use `vim.lsp.start()` (defined in `./lua/runtime/vim/lsp.lua`) which takes a `cmd` and `root_dir` arguments. The `start` calls the `start_client` function which will spawn the corresponding LSP server if none has been for this project (identified by the filetype and the `root_dir` argument in the configuration) and will create a RPC client to send requests to that server and handle its response with default handlers. The `start` method also "attaches" the client to the buffer so the server knows about that buffer and sets up all the relevant autocommands for the `BufPreWrite` and `BufPostWrite` events.

The LSP client is a RPC client either using TCP for transport or through local socket (pipe). The instantiation of the client invokes `libuv` to create the socket or the pipe. The source code is in `./lua/runtime/vim/lsp/rpc.lua`:
```lua
local function connect(host, port)
  return function(dispatchers)
    ...
    local tcp = uv.new_tcp()
    ...
 end
end
```
The `start_client` function also spawns the server process which is also
implemented in `./lua/runtime/vim/lsp/rpc.lua` through the `start` method which
underneath uses:
```lua
local function start(cmd, cmd_args, dispatchers, extra_spawn_params)
  ...
  handle, pid = uv.spawn(cmd, spawn_params, onexit)
  ...
end
```

The LSP module implements handlers for a bunch of different LSP request (check out `./lua/runtime/vim/lsp/handlers.lua`). Servers don't necessarily implement all of these requests though. You can customize those handlers with the `vim.lsp.with()` command.

The main function to look into is `vim.lsp.start_client()` (defined in `./lua/runtime/vim/lsp.lua`), where the client is set up. In particular, check the `client.request` function which executes the handler function on the response returned by the the LSP server subsequently to a request.

When a client is started and attached to a buffer it sets the `omnifunc`, `tagfunc` and `formatexpr` settings to the corresponding functions defined and implemented in the lsp module.

LSP servers also publish diagnostic which are mapped/transformed to vim diagnostics inside `./lua/runtime/vim/lsp/diagnostic.lua`:
```lua
vim.diagnostic.set(namespace, bufnr, diagnostic_lsp_to_vim(diagnostics, bufnr, client_id))
```

`on_init` is one of the keys of the `config` argument passed to `vim.lsp.start_client(config)`. `on_init` is a function called within the callback of the initialize function. There is also a `settings` parameter in the `config` Map which is passed as an argument to start client. These settings are sent to the LSP server with `workspace/didChangeConfiguration`. Here is the code:
```lua
function start_client(config)
  local rpc = lsp_rpc.start(...) -- this calls uv under the hood
  local client = { 
        -- ...
        rpc = rpc,
        -- ...
    }

  local function initialize()
    -- ...
    rpc.request('initialize', initialize_params, function(init_err, result)
      -- ...

      if next(config.settings) then
        client.notify('workspace/didChangeConfiguration', { settings = config.settings })
      end

      if config.on_init then
        local status, err = pcall(config.on_init, client, result)
        if not status then
          pcall(handlers.on_error, lsp.client_errors.ON_INIT_CALLBACK_ERROR, err)
        end
      end
      ...
    end
  end
  -- ...

  initialize()
end
```

`on_init` can be used to send extra parameters to the server after it started and update the running configuration of a LSP client.

The `settings` are also returned to the language server if requested via `workspace/configuration` (checkout the handler for that message in `./lua/runtime/vim/lsp/handlers.lua`)

NB: to check a particular servers capabilities, open a file for which the lsp client is configured and run: `:lua vim.print(vim.lsp.get_active_clients()[1].server_capabilities)`

## Neovim lspconfig plugin

The structure of this plugin is to lazily create a big table. Each time time you reference an element from that table like:
```lua
  local lspconfig = require('lspconfig')
  lspconfig.clangd.setup()
```
it lazily adds the element (`clangd` in this example) to the `lspconfig.configs` table through the `configs.__newindex` method (part of the metatable for `configs`). When doing so, it fetches the content of the object (`server_configuration.clangd`) by first validating the content of that object (its type) and adding a `setup` method to that language specific config.

The `lspconfig.manager` file deals with client management. In particular it instantiates them using `lsp.start_client` and `lsp.buf_attach_client` built-in methods.

For each LSP server, the `lspconfig` can add extra commands to issue particular request that this server supports. For example for the `clangd` LSP server (for the C language) it adds the `ClangdSwitchSourceHeader` which makes use of the existing client to send a 'textDocument/switchSourceHeader' request to `clangd`.

The arguments that you pass to the `setup` function of a config are passed as arguments to the `lsp.start_client()` method which is called underneath.

## clangd

`clangd` is the LSP server we chose for C and C++ languages.

When built, `clangd` wraps around clang to use its parsing mechanism. In Nix `clangd` is configured to look for system headers and implementations through environment variable it seems since `clangd` is actually a wrapped shell around the binary (check the wrapper file). That wrapper file refers to some configuration files in the `clang` derivation which is also a scirpt wrapping the binary with the right options. This wrapping script is created using the `wrapCCWith` function which generates a specific wrapping script for C compilers (gcc and `clang` namely). I guess it includes some checks specific to Nix if you want to rebuild some of your binaries with `clang` instead of `gcc`.

You can check how clang is configure by default with `clang -v -c -xc++ /dev/null`.

From the [official documentation](https://clangd.llvm.org/installation.html#project-setup):
```
To understand your source code, clangd needs to know your build flags. (This is just a fact of life in C++, source files are not self-contained).

By default, clangd will assume your code is built as clang some_file.cc, and you’ll probably get spurious errors about missing #included files, etc.
```
You will need to generate a `compile_commands.json` file for that. Refer to the official doc to set this up.

NB: `clang` is a C compiler (or frontend in the LLVM echosystem) which takes c files as input and creates an IR (Internal Representation) files. A lot of tools in the LLVM echosystem are able to manipulate IR files in particular there is an optimizer which can improve the efficiency of the code (some other tools can enrich the IR for debugging etc.). Other tools (backends) take an IR file and spit out the relevant machine code for the targeted architecture.

## Your mappings in Neovim

We have several moving parts:
- the built-in client requests which all LSP servers might not implement (you need to check the servers capability if you want to be neat)
- fzf-lua which provides some convenient wrappers around some of the built-in client requests
- nvim-cmp which provides sources for LSP based completions (nvim-cmp-lsp, nvim-cmp-lsp-signature-help for instance)

In `fzf-lua`, `lsp_finder` aggregates the results of all the lsp related queries. However that leads to duplicates, it seems like the `lsp-reference` provider captures everything fine most of the time so this is what we decide to have a mapping to.

`fzf-lua` checks the capability and prints a warning before aborting if the method is not supported, so we don't need to set those mappings inside an autocommand on the LspStart event, cf. `fzf-lua/providers/lsp.lua`:
```lua
local function wrap_fn(key, fn)
  return function(opts)
    opts = opts or {}
    opts.lsp_handler = handlers[key]
    opts.lsp_handler.capability = handler_capabilty(opts.lsp_handler)

    -- check_capabilities will print the approperiate warning
    if not check_capabilities(opts.lsp_handler) then
      return
    end
    -- Call the original method
    fn(opts)
  end
end
```

Also through the default lsp client implementation, when the client is attached to one buffer, `tagfunc` is set to `query_definition` (with a fallback on `query_workspace_symbols`), similarly for formatting and omnifunc, so there is no need to set some custom mappings to use LSP capabilities, using the usual mappings such as `C-]`, `gq`, etc. works fine with no extra setup.

Here are the mappings for all requests implemented by the built-in LSP client:
- `callHierarchy/incomingCalls`: N/A, this should be included in the result of references
- `callHierarchy/outgoingCalls`: N/A, this should be included in the result of references
- `textDocument/codeAction`: we use fzf-lua code action which basically registers its ui select function (which is its window with fzf running inside) and then calls the built-in client code action. In the implementation of the code action built-in client we see the following comment in `runtime/lua/lsp/buf.lua`:
```lua
---@private
--
--- This is not public because the main extension point is
--- vim.ui.select which can be overridden independently.
---
--- Can't call/use vim.lsp.handlers['textDocument/codeAction'] because it expects
--- `(err, CodeAction[] | Command[], ctx)`, but we want to aggregate the results
--- from multiple clients to have 1 single UI prompt for the user, yet we still
--- need to be able to link a `CodeAction|Command` to the right client for
--- `codeAction/resolve`
local function on_code_action_results(results, ctx, options)
...
end

--- Requests code actions from all clients and calls the handler exactly once
--- with all aggregated results
---@private
local function code_action_request(params, options)
  local bufnr = api.nvim_get_current_buf()
  local method = 'textDocument/codeAction'
  vim.lsp.buf_request_all(bufnr, method, params, function(results)
    local ctx = { bufnr = bufnr, method = method, params = params }
    on_code_action_results(results, ctx, options)
  end)
end
```
And in `fzf-lua/providers/lsp.lua`:
```lua
...
M.code_actions = function(opts)
...
  ui_select.register(opts, true, opts)
  vim.lsp.buf.code_action()
end
end
```
And in `fzf-lua/providers/ui_select.lua`:
```lua
...
M.register = function(opts, silent, opts_once)
  ...
  vim.ui.select = M.ui_select
  return true
end
...
```
- `textDocument/completion`: we will leverage nvim-cmp-lps sources to leverage this capability
- `textDocument/declaration`: N/A, this should be included in the result of references
- `textDocument/definition`: N/A, this should be included in the result of references
- `textDocument/documentHighlight`: this sends a query to the server to get all the highlighting necessary for the current buffer, the server responds with highlight groups and ranges, and the highlights are applied in the handler. It seems like this is not triggered automatically, however the built-in client has the following hook in `runtime/lua/lsp.lua`:
   ```lua
  function client._on_attach(bufnr)
    ...
    vim.schedule(function()
      if vim.tbl_get(client.server_capabilities, 'semanticTokensProvider', 'full') then
        semantic_tokens.start(bufnr, client.id)
      end
    end)
   ...
   ```
   if you look into `runtime/lua/lsp/semantic_tokens.lua` the following autocommand are created when the STHighlighter is instantiated with `new`:
   ```lua
      api.nvim_create_autocmd({ 'BufWinEnter', 'InsertLeave' }, {
        buffer = self.bufnr,
        group = self.augroup,
        callback = function()
          self:send_request()
        end,
      })
   ```
   The highlighting uses priorities to override the basic highlighting provided by TreeSitter
- `textDocument/documentSymbol`: we leverage fzf-lua wrapping method
- `textDocument/formatting`: we rely on nvim built-in mapping `gq`
- `textDocument/hover`: We set a custom mapping in a Hook after the LspAttach event
- `textDocument/implementation`: N/A, this should be included in the result of references
- `textDocument/publishDiagnostics`: we rely on fzf-lua wrapping method around the built-in client
- `textDocument/rangeFormatting`: we rely on nvim built-in mapping `gq`
- `textDocument/references`: the built-in handler populates the quickfix list with the results, but we use the fzf-lua wrapper to navigate the results:
   in `runtime/lua/vim/lsp/handlers.lua`
  ```lua
    M['textDocument/references'] = function(_, result, ctx, config)
         ...
        if config.loclist then
          vim.fn.setloclist(0, {}, ' ', { title = title, items = items, context = ctx })
          api.nvim_command('lopen')
        ...
        else
          vim.fn.setqflist({}, ' ', { title = title, items = items, context = ctx })
          api.nvim_command('botright copen')
        end
      end
    end
    ...
  ```
  but in `fzf-lua/providers/lsp.lua`:
  ```lua
    M.references = function(opts)
      return fzf_lsp_locations(opts, gen_lsp_contents)
    end

    local function fzf_lsp_locations(opts, fn_contents)
      ...
      opts = core.set_fzf_field_index(opts)
      opts = fn_contents(opts) -- adding the contents key here with the candidates
      if not opts.__contents then
        core.__CTX = nil
        return
      end
      return core.fzf_exec(opts.__contents, opts)
    end
  ```
  with `gen_lsp_contents` uses `lsp.buf_request_sync` (in the sync function) in `runtime/lua/vim/lsp.lua`:
  ```lua
    function lsp.buf_request_sync(bufnr, method, params, timeout_ms)
      local request_results

      -- this will make its way to client.request() but the handler function is
      -- overridden by this request_results assignment
      local cancel = lsp.buf_request_all(bufnr, method, params, function(it)
        request_results = it
      end)

      local wait_result, reason = vim.wait(timeout_ms or 1000, function()
        return request_results ~= nil
      end, 10)

      if not wait_result then
        cancel()
        return nil, wait_result_reason[reason]
      end

      return request_results
    end
  ```
  so it can do whatever it wishes with the results and the quickfix list is not populated
- `textDocument/rename`: We set a custom mapping in a Hook after the LspAttach event
- `textDocument/signatureHelp`: TODO (we will probably use nvim-cmp-lsp-signature-help for that)
- `textDocument/typeDefinition`: N/A, this should be included in the result of references
- `window/logMessage`: This is a server initiated request, this is handled by the nvim built-in lsp client
- `window/showMessage`: This is a server initiated request, this is handled by the nvim built-in lsp client
- `window/showDocument`: This is a server initiated request, this is handled by the nvim built-in lsp client
- `window/showMessageRequest`: This is a server initiated request, this is handled by the nvim built-in lsp client
- `workspace/applyEdit`: This is a server initiated request, this is handled by the nvim built-in lsp client
- `workspace/symbol`: we rely on fzf-lua wrapping method around the built-in client 

