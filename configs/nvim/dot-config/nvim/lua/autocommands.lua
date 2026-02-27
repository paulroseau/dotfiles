vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fzf',
  callback = function(args)
    vim.keymap.set('t', '<M-s>', '<M-s>', { buffer = args.buf })
    vim.keymap.set('t', '<M-v>', '<M-v>', { buffer = args.buf })
    vim.keymap.set('t', '<M-t>', '<M-t>', { buffer = args.buf })
  end,
})

local term_group = vim.api.nvim_create_augroup('TerminalConfig', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  group = term_group,
  callback = function(args)
    vim.keymap.set('', 'q', 'i', { buffer = args.buf })
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = term_group,
  callback = function(_)
    vim.cmd('startinsert')
  end,
})

vim.api.nvim_create_autocmd('TermClose', {
  group = term_group,
  callback = function(args)
    -- small defer so Neovim finishes cleaning up the terminal
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end)
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = term_group,
  pattern = 'term://*',
  callback = function(args)
    local saved_mode = vim.b[args.buf].term_mode
    if saved_mode == 't' or saved_mode == 'i' then
      vim.cmd('startinsert')
    end
    -- If saved_mode was 'n' (normal mode) or nil (first time), stay in normal mode
  end,
})

vim.api.nvim_create_autocmd('BufLeave', {
  group = term_group,
  pattern = 'term://*',
  callback = function(args)
    local mode = vim.api.nvim_get_mode().mode
    vim.b[args.buf].term_mode = mode
  end,
})
