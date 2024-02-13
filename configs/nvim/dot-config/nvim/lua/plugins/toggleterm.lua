require('toggleterm').setup({
  open_mapping = '<leader>t',
  shell = 'zsh',
  direction = 'float'
})

vim.api.nvim_create_autocmd('TermOpen', { 
  pattern = 'term://*toggleterm#*',
  callback = function(args)
    vim.keymap.set('', 'q', 'i', { buffer = args.buf })
  end
})
