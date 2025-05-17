local prefix = 'NvimInTmux'

local nvim_smart_windows = require("nvim-smart-windows").setup({
    augroup_name = prefix,
    command_prefix = prefix,
    do_preserve_zoomed_pane = true,
    client = {
      name = 'tmux',
      vim_mode_hook_id = 10, -- picked randomly, easiest way to add and remove one particular hook
    } 
}) 

if nvim_smart_windows then
  vim.keymap.set({'', 't'} , '<M-h>', '<cmd>' .. prefix .. 'Wincmd h<CR>')
  vim.keymap.set({'', 't'} , '<M-j>', '<cmd>' .. prefix .. 'Wincmd j<CR>')
  vim.keymap.set({'', 't'} , '<M-k>', '<cmd>' .. prefix .. 'Wincmd k<CR>')
  vim.keymap.set({'', 't'} , '<M-l>', '<cmd>' .. prefix .. 'Wincmd l<CR>')
end
