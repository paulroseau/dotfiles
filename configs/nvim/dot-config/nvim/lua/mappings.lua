vim.g.mapleader = ','
vim.opt.timeoutlen = 700 -- time in milliseconds that is waited for the next mapping key

-- Esc
vim.keymap.set({'', '!'} , '<leader>m', '<Esc>')

-- Navigate inside a wrapped line
vim.keymap.set({''} , '<up>', '<cmd>normal! gk<CR>')
vim.keymap.set({''} , '<down>', '<cmd>normal! gj<CR>')

-- Window switching (Follow up on https://github.com/neovim/neovim/issues/26881)
vim.keymap.set({'', 't'} , '<M-h>', '<cmd>wincmd h<CR>')
vim.keymap.set({'', 't'} , '<M-j>', '<cmd>wincmd j<CR>')
vim.keymap.set({'', 't'} , '<M-k>', '<cmd>wincmd k<CR>')
vim.keymap.set({'', 't'} , '<M-l>', '<cmd>wincmd l<CR>')

-- Window moving
vim.keymap.set({'', 't'} , '<M-H>', '<cmd>wincmd H<CR>')
vim.keymap.set({'', 't'} , '<M-J>', '<cmd>wincmd J<CR>')
vim.keymap.set({'', 't'} , '<M-K>', '<cmd>wincmd K<CR>')
vim.keymap.set({'', 't'} , '<M-L>', '<cmd>wincmd L<CR>')
vim.keymap.set({'', 't'} , '<M-x>', '<cmd>wincmd x<CR>')
vim.keymap.set({'', 't'} , '<M-r>', '<cmd>wincmd r<CR>')
vim.keymap.set({'', 't'} , '<M-R>', '<cmd>wincmd R<CR>')

-- Window resizing
vim.keymap.set({'', 't'} , '<M-=>', '<cmd>wincmd =<CR>')
vim.keymap.set({'', 't'} , '<M-+>', '<cmd>wincmd +<CR>')
vim.keymap.set({'', 't'} , '<M-->', '<cmd>wincmd -<CR>')
vim.keymap.set({'', 't'} , '<M->>', '<cmd>wincmd ><CR>')
vim.keymap.set({'', 't'} , '<M-<>', '<cmd>wincmd <<CR>')

-- Window creating
vim.keymap.set({'', 't'} , '<M-n>', '<cmd>wincmd n<CR>')
vim.keymap.set({'', 't'} , '<M-m>', '<cmd>vnew<CR>')
vim.keymap.set({''} , '<M-s>', '<cmd>wincmd s<CR>')
vim.keymap.set({''} , '<M-v>', '<cmd>wincmd v<CR>')
vim.keymap.set({''} , '<M-]>', '<C-w>g<C-]>')

-- Window closing
vim.keymap.set({'', 't'} , '<M-c>', '<cmd>wincmd c<CR>')
vim.keymap.set({'', 't'} , '<M-o>', '<cmd>wincmd o<CR>')

-- Tabpage creating
vim.keymap.set({'n'} , 'Tn', '<cmd>tabnew<CR>')
vim.keymap.set({'n'} , 'Tc', '<cmd>tabclose<CR>')
vim.keymap.set({''} , '<M-t>', '<cmd>wincmd T<CR>')
vim.keymap.set({''} , '<M-T>', '<cmd>wincmd T<CR><cmd>tabprevious<CR>')

-- Tabpage switching
vim.keymap.set({'n', 'v', 's'} , 'H', '<cmd>tabprevious<CR>')
vim.keymap.set({'n', 'v', 's'} , 'L', '<cmd>tabnext<CR>')

-- Tabpage moving
vim.keymap.set({''} , '<M-(>', '<cmd>-tabmove<CR>')
vim.keymap.set({''} , '<M-)>', '<cmd>+tabmove<CR>')

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
vim.keymap.set({''} , '<leader>L', toogle_boolean_option("list"))
vim.keymap.set({''} , '<leader>w', toogle_boolean_option("wrap"))

-- Clear whitespace
local function clear_trailing_whitespaces()
  local pos = vim.fn.getpos(".")
	-- need silent! for when the pattern is not found
	-- (keymap { silent = true } option is equivalent to silent not silent!, ie. errors will be echoed)
  vim.api.nvim_command([[silent! %substitute/[ \t]\+$//]])
  vim.fn.setpos(".", pos)
end
vim.keymap.set({''} , '<leader>W', clear_trailing_whitespaces)

-- Quit
vim.keymap.set({'n'} , '<leader>k', '<cmd>bwipeout!<CR>')

-- Terminal mappings
vim.keymap.set({'t'} , '<leader>m', [[<C-\><C-n>]])
