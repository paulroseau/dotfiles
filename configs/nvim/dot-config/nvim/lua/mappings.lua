vim.g.mapleader = ','
vim.opt.timeoutlen = 700 -- time in milliseconds that is waited for the next mapping key

-- Esc
vim.keymap.set({'', '!'} , '<leader>m', '<Esc>')

-- Navigate inside a wrapped line
vim.keymap.set({''} , '<up>', '<cmd>normal! gk<CR>')
vim.keymap.set({''} , '<down>', '<cmd>normal! gj<CR>')

-- Buffer switching
vim.keymap.set({'n'} , '<C-j>', '<cmd>bn<CR>')
vim.keymap.set({'n'} , '<C-k>', '<cmd>bp<CR>')

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
vim.keymap.set({'n'} , '<M-m>', '<cmd>vnew<CR>')
vim.keymap.set({'n'} , '<M-s>', '<C-w>s')
vim.keymap.set({'n'} , '<M-v>', '<C-w>v')
vim.keymap.set({'n'} , '<M-]>', '<C-w>g<C-]>')

-- Window closing
vim.keymap.set({'n'} , '<M-c>', '<C-w>c')
vim.keymap.set({'n'} , '<M-o>', '<C-w>o')

-- Tabpage creating
vim.keymap.set({'n'} , 'Tn', '<cmd>tabnew<CR>')
vim.keymap.set({'n'} , 'Tc', '<cmd>tabclose<CR>')
vim.keymap.set({'n'} , 'Tb', '<C-w>T')
vim.keymap.set({'n'} , 'Tp', '<C-w>T:tabprevious<CR>', { silent = true })

-- Tabpage switching
vim.keymap.set({'n'} , 'H', '<cmd>tabprevious<CR>')
vim.keymap.set({'n'} , 'L', '<cmd>tabnext<CR>')

-- Tabpage moving
vim.keymap.set({'n'} , '<M-(>', '<cmd>-tabmove<CR>')
vim.keymap.set({'n'} , '<M-)>', '<cmd>+tabmove<CR>')

-- Folds
vim.keymap.set({'n'} , '<M-e>', 'zm')
vim.keymap.set({'n'} , '<M-d>', 'zr')

-- Clear searchhighlighting
vim.keymap.set({''} , '<leader>,', '<cmd>nohlsearch<CR>')

-- Clear command line
vim.keymap.set({''} , '<BS>', ':<BS>')

-- Redo last command
vim.keymap.set({''} , ';', ':<UP><CR>')

-- Toggle settings
local function toogle_boolean_option(option_name)
  return function ()
    vim.o[option_name] = not vim.o[option_name]
  end
end
vim.keymap.set({''} , '<leader>l', toogle_boolean_option("list"))

-- Clear whitespace
local function clear_trailing_whitespaces()
  local pos = vim.fn.getpos(".")
	-- need silent! for when the pattern is not found
	-- (keymap { silent = true } option is equivalent to silent not silent!, ie. errors will be echoed)
  vim.api.nvim_command([[silent! %substitute/[ \t]\+$//]])
  vim.fn.setpos(".", pos)
end
vim.keymap.set({''} , '<leader>W', clear_trailing_whitespaces)
