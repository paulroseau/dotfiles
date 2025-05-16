local prefix = 'NvimInWezterm'

local nvim_smart_windows = require("nvim-smart-windows").setup({
    augroup_name = prefix,
    command_prefix = prefix,
    do_preserve_zoomed_pane = true,
    client = {
      name = 'wezterm',
      nvim_wezterm_user_var = 'is_nvim_running'
    } 
}) 

if nvim_smart_windows then
  vim.keymap.set({'', 't'} , '<M-h>', '<cmd>' .. prefix .. 'Wincmd h<CR>')
  vim.keymap.set({'', 't'} , '<M-j>', '<cmd>' .. prefix .. 'Wincmd j<CR>')
  vim.keymap.set({'', 't'} , '<M-k>', '<cmd>' .. prefix .. 'Wincmd k<CR>')
  vim.keymap.set({'', 't'} , '<M-l>', '<cmd>' .. prefix .. 'Wincmd l<CR>')
end
