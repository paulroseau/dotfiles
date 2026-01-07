require('render-markdown').setup({
  completions = {
    lsp = { enabled = true },
  },
  anti_conceal = {
    enabled = false, -- disable hiding added text on the line the cursor is on
  },
  sign = {
    enabled = false, -- no signs in the margin (avoids too much change)
  },
})

vim.keymap.set({ '' }, '<space>m', require('render-markdown').toggle)
