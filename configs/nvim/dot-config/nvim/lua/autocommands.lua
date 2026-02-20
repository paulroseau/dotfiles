vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args)
    vim.keymap.set('', 'q', 'i', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fzf',
  callback = function(args)
    vim.keymap.set('t', '<M-s>', '<M-s>', { buffer = args.buf })
    vim.keymap.set('t', '<M-v>', '<M-v>', { buffer = args.buf })
  end,
})
