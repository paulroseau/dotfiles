vim.g.mapleader = ','
vim.opt.timeoutlen = 700 -- time in milliseconds that is waited for the next mapping key

-- Esc
vim.keymap.set({'', '!'} , '<leader>m', '<Esc>')

-- Navigate inside a wrapped line
vim.keymap.set({''} , '<up>', '<cmd>normal! gk<CR>')
vim.keymap.set({''} , '<down>', '<cmd>normal! gj<CR>')

-- Window switching
vim.keymap.set({'n'} , '<M-h>', '<C-w>h')
vim.keymap.set({'n'} , '<M-j>', '<C-w>j')
vim.keymap.set({'n'} , '<M-k>', '<C-w>k')
vim.keymap.set({'n'} , '<M-l>', '<C-w>l')

-- Window moving
vim.keymap.set({'n'} , '<M-H>', '<C-w>H')
vim.keymap.set({'n'} , '<M-J>', '<C-w>J')
vim.keymap.set({'n'} , '<M-K>', '<C-w>K')
vim.keymap.set({'n'} , '<M-L>', '<C-w>L')
vim.keymap.set({'n'} , '<M-x>', '<C-w>x')
vim.keymap.set({'n'} , '<M-r>', '<C-w>r')
vim.keymap.set({'n'} , '<M-R>', '<C-w>R')

-- Window resizing
vim.keymap.set({'n'} , '<M-=>', '<C-w>=')
vim.keymap.set({'n'} , '<M-+>', '<C-w>+')
vim.keymap.set({'n'} , '<M-->', '<C-w>-')
vim.keymap.set({'n'} , '<M->>', '<C-w>>')
vim.keymap.set({'n'} , '<M-<>', '<C-w><')

-- Window creating
vim.keymap.set({'n'} , '<M-n>', '<C-w>n')
vim.keymap.set({'n'} , '<M-s>', '<C-w>s')
vim.keymap.set({'n'} , '<M-v>', '<C-w>v')
vim.keymap.set({'n'} , '<M-]>', '<C-w>g<C-]>')

-- Window closing
vim.keymap.set({'n'} , '<M-c>', '<C-w>c')
vim.keymap.set({'n'} , '<M-o>', '<C-w>o')

-- Tabpage creating
vim.keymap.set({'n'} , '<M-t>', '<C-w>T')
vim.keymap.set({'n'} , '<M-y>', '<C-w>T:tabprevious<CR>', { silent = true })

-- Tabpage switching
vim.keymap.set({'n'} , 'H', '<cmd>tabprevious<CR>', { silent = true })
vim.keymap.set({'n'} , 'L', '<cmd>tabnext<CR>', { silent = true })

-- Tabpage moving
vim.keymap.set({'n'} , '<M-(>', '<cmd>-tabmove<CR>', { silent = true })
vim.keymap.set({'n'} , '<M-)>', '<cmd>+tabmove<CR>', { silent = true })

-- Folds
vim.keymap.set({'n'} , '<M-e>', 'zm')
vim.keymap.set({'n'} , '<M-d>', 'zr')

-- Toggle settings
local function toogle_boolean_option(option_name)
  return function ()
    vim.o[option_name] = not vim.o[option_name]
  end
end
vim.keymap.set({''} , '<leader>,', toogle_boolean_option("hlsearch"))
vim.keymap.set({''} , '<leader>l', toogle_boolean_option("list"))
