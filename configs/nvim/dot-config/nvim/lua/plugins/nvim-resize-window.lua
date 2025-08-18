local resize_window = require("nvim-resize-window")

local increment = 3

vim.keymap.set({ '', 't' }, '<M-<>', resize_window.left(increment))
vim.keymap.set({ '', 't' }, '<M-+>', resize_window.down(increment))
vim.keymap.set({ '', 't' }, '<M-->', resize_window.up(increment))
vim.keymap.set({ '', 't' }, '<M->>', resize_window.right(increment))
