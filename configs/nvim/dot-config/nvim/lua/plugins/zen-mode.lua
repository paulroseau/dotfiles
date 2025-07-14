local zen = require('zen-mode')

zen.setup({
  window = {
    backdrop = 0.95,
    width = 0.80,
    height = 1,
    options = {
      signcolumn = "no", -- disable signcolumn
      number = false,    -- disable number column
      list = false,      -- disable whitespace characters
    },
  },
})

vim.keymap.set({ 'n' }, '<space><space>', zen.toggle)
