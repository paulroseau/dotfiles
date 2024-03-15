# nvim-cmp

Warning: this is a pretty complex plugin

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

One of the central method is the `core.confirm` method, which is implemented using the `feedkeys.call` function which in turn ends up using `vim.api.nvim_feedkeys`. This is a low level method that emulates typing keys in `nvim` (you can specify whether to interpret mappings or not, etc.). It seems to me that this method is a bit overkill since in most cases the only thing we pass to `nvim` is the callback function wrapped in a `<Cmd>lua v:lua....<CR>`, which to me looks like it could be just called directly. `core.confirm` takes an entry `e` as argument. This entry holds a record of type `lsp.CompletionItem`. My understanding is that it is an lsp type because it matches the LSP protocol (cf. response type of a LSP completion request: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#completionList). However other sources return such completion items without specifying all the fields (which are optional). For example the `nvim-cmp-buffer` source creates its result like so:
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
  -- self.source is the source impelmentation used
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

That's how the `source.entries` get updated. The logic to select the text from all the entry's fields is in the `core.confirm` method, in one of the `feedkeys.call` method, which is used just for the callback:
```lua
core.confirm = function(self, e, option, callback)
  ...
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
