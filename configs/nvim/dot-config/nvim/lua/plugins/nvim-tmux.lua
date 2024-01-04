if require("nvim-tmux").setup() then
  vim.keymap.set({'', 't'} , '<M-h>', '<cmd>NvimTmuxWincmd h<CR>')
  vim.keymap.set({'', 't'} , '<M-j>', '<cmd>NvimTmuxWincmd j<CR>')
  vim.keymap.set({'', 't'} , '<M-k>', '<cmd>NvimTmuxWincmd k<CR>')
  vim.keymap.set({'', 't'} , '<M-l>', '<cmd>NvimTmuxWincmd l<CR>')
end
