-- Leader key
vim.g.mapleader = ','

-- Esc
vim.keymap.set({'', 's', 'i'}, '<leader>m', '<Esc>')
vim.keymap.set({'c'}, '<leader>m', '<C-c>')
vim.keymap.set({'t'}, '<leader>m', [[<C-\><C-n>]])

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
vim.keymap.set({''} , '<M-c>', '<C-w>c')
vim.keymap.set({''} , '<M-o>', '<C-w>o')

-- Tabpage creating
vim.keymap.set({'n'} , 'Tn', '<cmd>tabnew<CR>')
vim.keymap.set({'n'} , 'Tc', '<cmd>tabclose<CR>')
vim.keymap.set({''} , '<M-t>', '<C-w>T')
vim.keymap.set({''} , '<M-T>', '<C-w>T<cmd>tabprevious<CR>')

-- Tabpage switching
vim.keymap.set({'n', 'v', 's'} , 'H', '<cmd>tabprevious<CR>')
vim.keymap.set({'n', 'v', 's'} , 'L', '<cmd>tabnext<CR>')

-- Tabpage moving
vim.keymap.set({''} , '(', '<cmd>-tabmove<CR>')
vim.keymap.set({''} , ')', '<cmd>+tabmove<CR>')

-- Folds
vim.keymap.set({''} , '<M-e>', 'zm')
vim.keymap.set({''} , '<M-d>', 'zr')

-- Clear search highlighting
vim.keymap.set({''} , '<leader>,', '<cmd>nohlsearch<CR>')

-- Clear command line
vim.keymap.set({''} , '<BS>', ':<BS>')

-- Redo last command
vim.keymap.set({''} , '\\', ':<UP><CR>')

-- Toggle settings
local function toogle_boolean_option(option_name)
  return function ()
    vim.o[option_name] = not vim.o[option_name]
  end
end
vim.keymap.set({''} , '<leader><Space>', toogle_boolean_option("list"))
vim.keymap.set({''} , '<leader>w', toogle_boolean_option("wrap"))

-- Better * and # searches
local function visual_selection_search(search_character)
  return function ()
    local previous_s_register = vim.fn.getreg('s')
    vim.cmd('normal! "sy')
    local search_pattern = vim.fn.escape(vim.fn.getreg('s'), '\\' .. search_character)
    search_pattern = vim.fn.substitute(search_pattern, '\n', '\\\\n', 'g')
    vim.fn.setreg('s', previous_s_register)
    vim.cmd("silent! " .. search_character .. "\\V" .. search_pattern)
  end
end
vim.keymap.set({'v'}, '*', visual_selection_search('/'))
vim.keymap.set({'v'}, '#', visual_selection_search('?'))

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

-- Remove buffer quickly with C-x
vim.keymap.set({'n'} , '<C-s>', '<C-x>') -- remap substract number to <C-s> first
vim.keymap.set({'n'} , '<C-x>', '<cmd>bwipeout!<CR>')

-- Hack! <C-Space> is interpreted by the terminal as <C-@> which is a built-in mapping (check :help *i_CTRL-@*)
-- This gets annoying with auto-completion
vim.keymap.set({'i'}, '<C-Space>', ' ')

-- Navigate the quickfix
local function locationlist_or_quickfixlist(action)
  return function ()
    local locations = vim.fn.getloclist(0)
    if not vim.tbl_isempty(locations) then
      vim.cmd("silent! l" .. action)
    else
      vim.cmd("silent! c" .. action)
    end
  end
end

vim.keymap.set({'n'} , '<C-p>', locationlist_or_quickfixlist("previous"))
vim.keymap.set({'n'} , '<C-n>', locationlist_or_quickfixlist("next"))

-- LSP mappings

-- Fall back method when no LSP client is attached or no attached client
-- supports renaming
local function rename_with_substitute()
  local cword = vim.fn.expand('<cword>')
  local prompt_opts = {
    prompt = 'New Name: ',
    default = cword,
  }

  vim.ui.input(prompt_opts, function(input)
    if not input or #input == 0 then
      return
    end
    local pos = vim.fn.getpos(".")
    local substitute_cmd = string.format("%%substitute/\\<%s\\>/%s/eg", cword, input)
    vim.cmd(substitute_cmd)
    vim.cmd("nohlsearch")
    vim.fn.setpos(".", pos)
  end)
end

-- Unfortunately vim.lsp.buf.rename does not change its return type if no client
-- with adequate capability is found, so we need to wrap it to fall back on our
-- hand made method
-- This was adapted from runtime/lua/vim/lsp/buf.lua
local function wrapped_lsp_buf_rename()
  local bufnr = vim.api.nvim_get_current_buf()
  local lsp_clients = vim.lsp.get_active_clients({ bufnr = bufnr, })

  -- Clients must at least support rename, prepareRename is optional
  lsp_clients = vim.tbl_filter(function(client)
    return client.supports_method('textDocument/rename')
  end, lsp_clients)

  if #lsp_clients == 0 then
    vim.notify('[LSP] Rename, no matching language servers with rename capability, using builtin substitute instead')
    rename_with_substitute()
  else
    vim.lsp.buf.rename()
  end
end

vim.keymap.set({'n'}, '<leader>R', wrapped_lsp_buf_rename)
vim.keymap.set({'n'}, 'K', vim.lsp.buf.hover)
