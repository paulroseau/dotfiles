local cmp = require('cmp')

local complete_if_invisible = function(if_visible_fn)
  return function(fallback)
    if cmp.visible() then
      if_visible_fn()
    else
      cmp.complete()
    end
  end
end

cmp.setup({
  mapping = cmp.mapping({
    ['<C-n>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })),
      { 'i', 'c' }
    ),
    ['<C-p>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })),
      { 'i', 'c' }
    ),
    ['<C-j>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })),
      { 'i', 'c' }
    ),
    ['<C-k>'] = cmp.mapping(
      complete_if_invisible(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })),
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
    { name = 'nvim_lua' },
    { name = 'path' },
    { name = 'buffer', keyword_length = 2, },
  }),
})

cmp.setup.cmdline({'/'}, {
  sources = {
    { name = 'buffer', keyword_length = 2, }
  }
})

cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'cmdline' },
    { name = 'nvim_lua'},
    { name = 'path' },
  })
})
