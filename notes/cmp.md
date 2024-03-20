# nvim-cmp

Warning: this is a pretty complex plugin

## Configuration

The architecture relies on sources, which need to implement a particular interface. If you look into the `nvim-cmp/lua/source.lua` source, you will see a source is created by passing around a `s` which will be assigned to `self.source`. `s` must implement a series of function, in particular `complete`. Some are optional since `nvim-cmp` calls them with an `if` in front:
```lua
source.is_available = function(self)
  if self.source.is_available then
    return self.source:is_available()
  end
  return true
end
```

All `cmp-*` plugins which implement a source, register themselves as an
available sources in their `./after` directory:
```lua
require('cmp').register_source('path', require('cmp_path').new())
```

That means `nvim-cmp` needs to be in the runtimepath.

For mappings, you can specify if a mapping should be active in insert mode or command mode (for `:` and `/`).

The `config` object has a `__call` meta methods which resolves to setting the value passed as a field of that object through doing some checks via the normalize function. Also some utility methods are mapped to it such as `set_cmdline` which allows to set configuration for a particular type of cmdline (`:`, `/`) for example.

## Snippet support

LSP servers can return completion items which support snippets. These snippets are returned as a string which follows a particular syntax: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#snippet_syntax. Upon confirmation on such an iterm, `nvim-cmp` will call the expand function configured in nvim-cmp as the snippet key.
```lua
core.confirm = function(self, e, option, callback)
  ...
  if is_snippet then
    config.get().snippet.expand({
      body = new_text,
      insert_text_mode = completion_item.insertTextMode,
    })
  end
  ...
end
```

Snippets will thus be returned by LSP servers if they implement them, but if you want to define your own snippets, these will not be completed by default. If you want that then you can install a specific sources which will look into the snippets defined by your Snippet engine (LuaSnip in your case: https://github.com/saadparwaiz1/cmp_luasnip)

## Completion

One of the central method is the `core.confirm` method, which is implemented using the `feedkeys.call` function which in turn ends up using `vim.api.nvim_feedkeys`. This is a low level method that emulates typing keys in `nvim` (you can specify how to interpret the keys, with mappings enabled or not, etc.). It seems to me that this method is a bit overkill since in most cases the only thing we pass to `nvim` is the callback function wrapped in a `<Cmd>lua v:lua....<CR>`, which to me looks like it could be just called directly. `core.confirm` takes an entry `e` as argument. This entry holds a record of type `lsp.CompletionItem`. My understanding is that it is an lsp type because it matches the LSP protocol (cf. response type of a LSP completion request: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionList). However other sources return such completion items without specifying all the fields (which are optional). For example the `nvim-cmp-buffer` source creates its result like so:
```lua
source.complete = function(self, params, callback)
  ...

  vim.defer_fn(function()
    local input = string.sub(params.context.cursor_before_line, params.offset)
    local items = {}
    local words = {}
    for _, buf in ipairs(bufs) do
      for _, word_list in ipairs(buf:get_words()) do
        for word, _ in pairs(word_list) do
          if not words[word] and input ~= word then
            words[word] = true
            table.insert(items, {
              label = word,
              dup = 0,
            })
          end
        end
      end
    end

    callback({
      items = items,
      isIncomplete = processing,
    })
  end, processing and 100 or 0)
end
```
and this one is wrapped inside `nvim-cmp` `source.complete` method:
```lua
source.complete = function(self, ctx, callback)
  ...
  -- self.source is the source implementation used
  self.source:complete(
    vim.tbl_extend('keep', misc.copy(self:get_source_config()), { -- this is the params
      offset = self.offset,
      context = ctx,
      completion_context = completion_context,
    }),
    self.complete_dedup(vim.schedule_wrap(function(response) -- this is the callback
      -- ...
      if #(response.items or response) > 0 then
        -- ...
        self.status = source.SourceStatus.COMPLETED
        self.entries = {}
        for _, item in ipairs(response.items or response) do
          if (item or {}).label then
            local e = entry.new(ctx, self, item, response.itemDefaults)
            if not e:is_invalid() then
              table.insert(self.entries, e)
              self.offset = math.min(self.offset, e:get_offset())
            end
          end
        end
        -- ...
      end
      callback()
    end))
  )
```

That's how the `source.entries` get updated. The logic to select the text from all the entry's fields is in the `core.confirm` method, in one of the `feedkeys.call` method, which is used just for the callback (no keys are actually fed):
```lua
core.confirm = function(self, e, option, callback)
  ...
  feedkeys.call('', 'n', function() ... end)
  feedkeys.call('', 'n', function() ... end)

  feedkeys.call('', 'n', function()
    local ctx = context.new()
    local completion_item = misc.copy(e:get_completion_item())
    if not completion_item.textEdit then
      completion_item.textEdit = {}
      local insertText = completion_item.insertText
      if misc.empty(insertText) then
        insertText = nil
      end
      completion_item.textEdit.newText = insertText or completion_item.word or completion_item.label -- this is how label is picked for the nvim-cmp-buffer source
    end
    ...
    local is_snippet = completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet -- this will be true only for entries returned by an LSP server (the nvim-cmp-lsp does not do any wrapping, so I guess nvim-cmp was coded with that use case in mind)
    if is_snippet then
      completion_item.textEdit.newText = ''
    end
    ...
    -- so in case the LSP server returns an insertTextFormat = 2
    -- as part of its response you will need to have an expand function implemented.
    -- (cf. -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#insertTextFormat)
    if is_snippet then
      config.get().snippet.expand({
        body = new_text,
        insert_text_mode = completion_item.insertTextMode,
      })
    end
  )
  ...
end
```

## Mappings

Mappings are defined as a map of mode and lhs to functions which take a `fallback` argument. `fallback` is supposed to represent whatever "rhs action" (callback function to call, or keys to feed send to nvim through nvim_feedkeys) is already assigned to the lhs. The keymap setting is done in 2 steps:
1. for all modes and lhs in the config we resovle the existing fallback method (done in the `keymap.listen` method)
2. we assign for all keys (mode and lhs) a function which will call the configured function for that pair of mode/keys with the right fallback as argument (the look up of the configured function is done in `core.on_keymap`, the passing of the resovled `fallback` method is done in `keymap.listen`)

The setup of the mappings starts in the `core.prepare` method in `cmp/core.lua`:
```lua
core.prepare = function(self)
  for keys, mapping in pairs(config.get().mapping) do
    for mode in pairs(mapping) do
      -- keymap.listen assigns the same function for all mapping
      keymap.listen(mode, keys, function(...)
        self:on_keymap(...)
      end)
    end
  end
end

-- inside on_keymap we resolve which keys was called and call the appropriate
-- function by passing the fallback function to it
core.on_keymap = function(self, keys, fallback)
  local mode = api.get_mode()
  for key, mapping in pairs(config.get().mapping) do
    if keymap.equals(key, keys) and mapping[mode] then
      return mapping[mode](fallback)
    end
  end

  -- other stuff below related to confirmation of the key, on_keymap is also
  -- registered as a hook to self.view.on(...), didn't dig into that
  ...
end
```

`keymap.listen` in `cmp/utils/keymap.lua` sets up the mappings in way such that if the keys in `lhs` were already assigned to some function, then we resovle that function and pass it as an argument to the new mapping function (named `callback` in here, to which `on_keymap` is assigned):
```lua
keymap.listen = function(mode, lhs, callback)
  lhs = keymap.normalize(keymap.to_keymap(lhs))

  local existing = keymap.get_map(mode, lhs)
  if existing.desc == 'cmp.utils.keymap.set_map' then
    return
  end

  local bufnr = existing.buffer and vim.api.nvim_get_current_buf() or -1
  local fallback = keymap.fallback(bufnr, mode, existing)
  keymap.set_map(bufnr, mode, lhs, function()
    local ignore = false
    ignore = ignore or (mode == 'c' and vim.fn.getcmdtype() == '=')
    if ignore then
      fallback()
    else
      callback(lhs, misc.once(fallback)) -- core.prepare makes this is core.on_keymap
    end
  end, {
    expr = false,
    noremap = true,
    silent = true,
  })
end

-- keymap.set_map is a small wrapper around nvim_set_keymap/nvim_buf_set_keymap
keymap.set_map = function(bufnr, mode, lhs, rhs, opts)
  if type(rhs) == 'function' then
    opts.callback = rhs
    rhs = ''
  end

  opts.desc = 'cmp.utils.keymap.set_map'
  ...
  if bufnr == -1 then
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  else
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
  end
end

-- keymap.fallback creates the appropriate fallback function based on how the original mapping was defined
keymap.fallback = function(bufnr, mode, map)
  return function()
    if map.expr then
      -- creating an invisible mapping
      local fallback_lhs = string.format('<Plug>(cmp.u.k.fallback_expr:%s)', map.lhs)
      keymap.set_map(bufnr, mode, fallback_lhs, function()
        return keymap.solve(bufnr, mode, map).keys
      end, { ... })
      vim.api.nvim_feedkeys(keymap.t(fallback_lhs), 'im', true)
    elseif map.callback then
      -- note that the documentation for nvim.api.nvim_set_keymap says for the
      -- opt.callback value:
      -- "callback" Lua function called in place of {rhs}
      -- so the plugin just replicates the logic here (I guess nvim does the
      -- same thing as nvim_cmp does when setting keymap, ie. if the rhs is a
      -- function it just assigns it to opts.callback
      map.callback()  --
    else
      local solved = keymap.solve(bufnr, mode, map)
      vim.api.nvim_feedkeys(solved.keys, solved.mode, true)
    end
  end
end
```
