vim.g.mapleader = ','
vim.opt.timeoutlen = 700 -- time in milliseconds that is waited for the next mapping key

-- Esc
vim.keymap.set({'', 'i', 'c'} , '<leader>m', '<C-c>')
vim.keymap.set({'t'} , '<leader>m', [[<C-\><C-n>]])

-- Navigate inside a wrapped line
vim.keymap.set({''} , '<up>', '<cmd>normal! gk<CR>')
vim.keymap.set({''} , '<down>', '<cmd>normal! gj<CR>')

-- Window switching (Follow up on https://github.com/neovim/neovim/issues/26881)
vim.keymap.set({'', 't'} , '<M-h>', '<C-w>h')
vim.keymap.set({'', 't'} , '<M-j>', '<C-w>j')
vim.keymap.set({'', 't'} , '<M-k>', '<C-w>k')
vim.keymap.set({'', 't'} , '<M-l>', '<C-w>l')

-- Window moving
vim.keymap.set({'', 't'} , '<M-H>', '<C-w>H')
vim.keymap.set({'', 't'} , '<M-J>', '<C-w>J')
vim.keymap.set({'', 't'} , '<M-K>', '<C-w>K')
vim.keymap.set({'', 't'} , '<M-L>', '<C-w>L')
vim.keymap.set({'', 't'} , '<M-x>', '<C-w>x')
vim.keymap.set({'', 't'} , '<M-r>', '<C-w>r')
vim.keymap.set({'', 't'} , '<M-R>', '<C-w>R')

-- Window resizing
vim.keymap.set({'', 't'} , '<M-=>', '<C-w>=')
vim.keymap.set({'', 't'} , '<M-+>', '<C-w>+')
vim.keymap.set({'', 't'} , '<M-->', '<C-w>-')
vim.keymap.set({'', 't'} , '<M->>', '<C-w>>')
vim.keymap.set({'', 't'} , '<M-<>', '<C-w><')

-- Window creating
vim.keymap.set({'', 't'} , '<M-n>', '<cmd>new<CR>')
vim.keymap.set({'', 't'} , '<M-m>', '<cmd>vnew<CR>')
vim.keymap.set({''} , '<M-s>', '<C-w>s')
vim.keymap.set({''} , '<M-v>', '<C-w>v')
vim.keymap.set({''} , '<M-]>', '<C-w>g<C-]>')

-- Window closing
vim.keymap.set({'', 't'} , '<M-c>', '<C-w>c')
vim.keymap.set({'', 't'} , '<M-o>', '<C-w>o')

-- Tabpage creating
vim.keymap.set({'n'} , 'Tn', '<cmd>tabnew<CR>')
vim.keymap.set({'n'} , 'Tc', '<cmd>tabclose<CR>')
vim.keymap.set({''} , '<M-t>', '<C-w>T<CR>')
vim.keymap.set({''} , '<M-T>', '<C-w>T<CR><cmd>tabprevious<CR>')

-- Tabpage switching
vim.keymap.set({'n', 'v', 's'} , 'H', '<cmd>tabprevious<CR>')
vim.keymap.set({'n', 'v', 's'} , 'L', '<cmd>tabnext<CR>')

-- Tabpage moving
vim.keymap.set({''} , '<M-(>', '<cmd>-tabmove<CR>')
vim.keymap.set({''} , '<M-)>', '<cmd>+tabmove<CR>')

-- Easier scrolling
vim.keymap.set({''} , '<C-e>', '<C-u>')
vim.keymap.set({''} , '<C-u>', '<C-e>')

-- Folds
vim.keymap.set({''} , '<M-e>', 'zm')
vim.keymap.set({''} , '<M-d>', 'zr')

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
vim.keymap.set({''} , '<leader><Space>', toogle_boolean_option("list"))
vim.keymap.set({''} , '<leader>w', toogle_boolean_option("wrap"))

-- Clear whitespace
local function clear_trailing_whitespaces()
  local pos = vim.fn.getpos(".")
	-- need silent! for when the pattern is not found
	-- (keymap { silent = true } option is equivalent to silent not silent!, ie. errors will be echoed)
  vim.cmd([[silent! %substitute/[ \t]\+$//]])
  vim.cmd("nohlsearch")
  vim.fn.setpos(".", pos)
end

vim.keymap.set({''} , '<leader>W', clear_trailing_whitespaces)

-- Quit
vim.keymap.set({'n'} , '<leader>k', '<cmd>bwipeout!<CR>')

-- Hack! <C-Space> is interpreted by the terminal as <C-@> which is a built-in mapping (check :help *i_CTRL-@*)
-- This gets annoying with auto-completion
vim.keymap.set({'i'}, '<C-Space>', ' ')

-- Terminal mappings
vim.keymap.set({'t'} , '<leader>m', [[<C-\><C-n>]])
