local utils = require('mappings.utils')

-- Leader key
vim.g.mapleader = ','

-- Esc
vim.keymap.set({ '', 's', 'i' }, '<leader>m', '<Esc>')
vim.keymap.set({ 'c' }, '<leader>m', '<C-c>')
vim.keymap.set({ 't' }, '<leader>m', [[<C-\><C-n>]])

-- Tcsh for command mode
vim.keymap.set({ 'c' }, '<C-a>', '<Home>')
vim.keymap.set({ 'c' }, '<C-e>', '<End>')
vim.keymap.set({ 'c' }, '<C-f>', '<Right>')
vim.keymap.set({ 'c' }, '<C-b>', '<Left>')
vim.keymap.set({ 'c' }, '<C-d>', '<Del>')
vim.keymap.set({ 'c' }, '<Esc>b', '<S-Left>')
vim.keymap.set({ 'c' }, '<Esc>f', '<S-Right>')

-- Navigate inside a wrapped line
vim.keymap.set({ '' }, '<up>', '<cmd>normal! gk<CR>')
vim.keymap.set({ '' }, '<down>', '<cmd>normal! gj<CR>')

-- Window switching (Follow up on https://github.com/neovim/neovim/issues/26881)
vim.keymap.set({ '', 't' }, '<M-h>', '<cmd>wincmd h<CR>')
vim.keymap.set({ '', 't' }, '<M-j>', '<cmd>wincmd j<CR>')
vim.keymap.set({ '', 't' }, '<M-k>', '<cmd>wincmd k<CR>')
vim.keymap.set({ '', 't' }, '<M-l>', '<cmd>wincmd l<CR>')

-- Window moving
vim.keymap.set({ '', 't' }, '<M-H>', '<cmd>wincmd H<CR>')
vim.keymap.set({ '', 't' }, '<M-J>', '<cmd>wincmd J<CR>')
vim.keymap.set({ '', 't' }, '<M-K>', '<cmd>wincmd K<CR>')
vim.keymap.set({ '', 't' }, '<M-L>', '<cmd>wincmd L<CR>')
vim.keymap.set({ '', 't' }, '<M-x>', '<cmd>wincmd x<CR>')
vim.keymap.set({ '', 't' }, '<M-r>', '<cmd>wincmd r<CR>')
vim.keymap.set({ '', 't' }, '<M-R>', '<cmd>wincmd R<CR>')

-- Window resizing
vim.keymap.set({ '', 't' }, '<M-=>', '<cmd>wincmd =<CR>')
vim.keymap.set({ '', 't' }, '<M-+>', '<cmd>execute v:count1 .. "wincmd +"<CR>')
vim.keymap.set({ '', 't' }, '<M-->', '<cmd>execute v:count1 .. "wincmd -"<CR>')
vim.keymap.set({ '', 't' }, '<M->>', '<cmd>execute v:count1 .. "wincmd >"<CR>')
vim.keymap.set({ '', 't' }, '<M-<>', '<cmd>execute v:count1 .. "wincmd <"<CR>')

-- Window creating
vim.keymap.set({ '', 't' }, '<M-n>', '<cmd>new<CR>')
vim.keymap.set({ '', 't' }, '<M-m>', '<cmd>vnew<CR>')
vim.keymap.set({ '' }, '<M-s>', '<cmd>wincmd s<CR>')
vim.keymap.set({ '' }, '<M-v>', '<cmd>wincmd v<CR>')
vim.keymap.set({ '' }, '<M-]>', '<C-w>g<C-]>')

-- Window closing
vim.keymap.set({ '', 't' }, '<M-c>', '<cmd>close<CR>')
vim.keymap.set({ '', 't' }, '<M-o>', '<cmd>only<CR>')

-- Tabpage creating
vim.keymap.set({ 'n' }, 'Tn', '<cmd>tabnew<CR>')
vim.keymap.set({ 'n' }, 'Tc', '<cmd>tabclose<CR>')
vim.keymap.set({ '' }, '<M-t>', '<cmd>wincmd T<CR>')
vim.keymap.set({ '' }, '<M-T>', '<C-w>T<cmd>tabprevious<CR>')

-- Tabpage switching
vim.keymap.set({ 'n', 'v', 's' }, 'H', '<cmd>tabprevious<CR>')
vim.keymap.set({ 'n', 'v', 's' }, 'L', '<cmd>tabnext<CR>')

-- Tabpage moving
vim.keymap.set({ '' }, '(', '<cmd>-tabmove<CR>')
vim.keymap.set({ '' }, ')', '<cmd>+tabmove<CR>')

-- Folds
vim.keymap.set({ '' }, '<M-e>', 'zm')
vim.keymap.set({ '' }, '<M-d>', 'zr')

-- Terminal
vim.keymap.set({ '' }, 'tt', '<cmd>terminal<CR>')
vim.keymap.set('t', '<M-s>', utils.cmd_then_terminal('wincmd s'))
vim.keymap.set('t', '<M-v>', utils.cmd_then_terminal('wincmd v'))
vim.keymap.set('t', '<M-t>', utils.cmd_then_terminal('tabnew'))

-- Clear search highlighting
vim.keymap.set({ '' }, '<leader>,', '<cmd>nohlsearch<CR>')

-- Clear command line
vim.keymap.set({ '' }, '<BS>', ':<BS>')

-- Redo last command
vim.keymap.set({ '' }, '\\', ':<UP><CR>')

-- Toggle settings
vim.keymap.set({ '' }, '<leader><Space>', utils.toogle_boolean_option('list'))
vim.keymap.set({ '' }, '<leader>w', utils.toogle_boolean_option('wrap'))

-- Better * and # searches
vim.keymap.set({ 'v' }, '*', utils.visual_selection_search('/'))
vim.keymap.set({ 'v' }, '#', utils.visual_selection_search('?'))

-- Clear whitespace
vim.keymap.set({ '' }, '<leader>W', utils.clear_trailing_whitespaces)

-- Remove buffer quickly with C-x
vim.keymap.set({ 'n' }, '<C-s>', '<C-x>') -- remap substract number to <C-s> first
vim.keymap.set({ 'n' }, '<C-x>', '<cmd>bwipeout!<CR>')

-- Hack! <C-Space> is interpreted by the terminal as <C-@> which is a built-in mapping (check :help *i_CTRL-@*)
-- This gets annoying with auto-completion
vim.keymap.set({ 'i' }, '<C-Space>', ' ')

-- Navigate the quickfix
vim.keymap.set({ 'n' }, '<C-p>', utils.locationlist_or_quickfixlist('previous'))
vim.keymap.set({ 'n' }, '<C-n>', utils.locationlist_or_quickfixlist('next'))

-- Snippet
vim.keymap.set({ 'i', 's' }, '<C-p>', function()
  vim.snippet.jump(-1)
end, { desc = 'Snippet jump backward', silent = true })
vim.keymap.set({ 'i', 's' }, '<C-n>', function()
  vim.snippet.jump(1)
end, { desc = 'Snippet jump forward', silent = true })

-- Renaming

vim.keymap.set({ 'n' }, '<leader>R', vim.lsp.buf.rename)
vim.keymap.set({ 'n' }, '<leader>M', utils.rename_with_substitute)

-- Formatting
vim.keymap.set({ 'n', 'v' }, '<leader>F', vim.lsp.buf.format)

local function call_twice(fn)
  return function()
    fn()
    fn()
  end
end

-- Hover (call twice to focus inside the preview window)
vim.keymap.set({ 'n' }, 'K', call_twice(vim.lsp.buf.hover))
