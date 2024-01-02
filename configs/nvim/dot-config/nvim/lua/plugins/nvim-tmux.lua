if require("nvim-tmux").setup() then
  vim.keymap.set({'n', 'v'} , '<M-h>', '<cmd>NvimTmuxWincmd h<CR>')
  vim.keymap.set({'n', 'v'} , '<M-j>', '<cmd>NvimTmuxWincmd j<CR>')
  vim.keymap.set({'n', 'v'} , '<M-k>', '<cmd>NvimTmuxWincmd k<CR>')
  vim.keymap.set({'n', 'v'} , '<M-l>', '<cmd>NvimTmuxWincmd l<CR>')
end
