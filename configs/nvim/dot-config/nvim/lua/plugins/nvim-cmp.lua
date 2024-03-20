local cmp = require('cmp')

local complete_if_invisible = function(callback)
  return function(_)
    if cmp.visible() then
      callback()
    else
      cmp.complete()
    end
  end
end

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  mapping = cmp.mapping({
    ['<C-j>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })),
      { 'i', 'c' }
    ),
    ['<C-k>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })),
      { 'i', 'c' }
    ),
    ['<C-c>'] = cmp.mapping(
      cmp.mapping.abort(),
      { 'i', 'c' }
    ),
    ['<CR>'] = cmp.mapping({
      i = cmp.mapping.confirm({ select = true }),
      c = cmp.mapping.confirm({ select = false }),
    }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'nvim_lua' },
    { name = 'path' },
    { name = 'buffer',   keyword_length = 2, },
  }),
})

cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'cmdline', keyword_length = 3, },
    { name = 'nvim_lua' }, -- works only if you are editing a lua file :-(
    { name = 'path' },
  })
})
