require("nvim-resize-window").setup()
vim.keymap.set({'', 't'} , '<M-<>', '<cmd>ResizeWinLeft<CR>')
vim.keymap.set({'', 't'} , '<M-+>', '<cmd>ResizeWinDown<CR>')
vim.keymap.set({'', 't'} , '<M-->', '<cmd>ResizeWinUp<CR>')
vim.keymap.set({'', 't'} , '<M->>', '<cmd>ResizeWinRight<CR>')

