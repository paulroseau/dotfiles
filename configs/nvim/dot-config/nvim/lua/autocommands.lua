vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fzf',
  callback = function(args)
    vim.keymap.set('t', '<M-s>', '<M-s>', { buffer = args.buf })
    vim.keymap.set('t', '<M-v>', '<M-v>', { buffer = args.buf })
    vim.keymap.set('t', '<M-t>', '<M-t>', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args)
    vim.keymap.set('', 'q', 'i', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
  pattern = 'term://*',
  callback = function(_)
    vim.cmd('startinsert')
  end,
})

vim.api.nvim_create_autocmd('TermClose', {
  callback = function(args)
    -- small defer so Neovim finishes cleaning up the terminal
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end)
  end,
})
