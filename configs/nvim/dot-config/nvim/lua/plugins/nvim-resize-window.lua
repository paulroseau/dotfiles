local resize_window = require('nvim-resize-window')

local default_increment = 3

local function with_count(resize_function)
  return function()
    local count = vim.v.count > 0 and vim.v.count or default_increment
    resize_function(count)()
  end
end

vim.keymap.set({ '', 't' }, '<M-<>', with_count(resize_window.left))
vim.keymap.set({ '', 't' }, '<M-+>', with_count(resize_window.down))
vim.keymap.set({ '', 't' }, '<M-->', with_count(resize_window.up))
vim.keymap.set({ '', 't' }, '<M->>', with_count(resize_window.right))
