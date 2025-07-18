-- General
vim.o.textwidth = 80 -- lines length limit (0 if no limit)
vim.o.showmatch = true -- shows matching parenthesis
vim.o.matchtime = 2 -- time during which the matching parenthesis is shown
vim.o.linebreak = true -- don't cut lines in the middle of a word
vim.o.number = true -- show line numbers
vim.o.showmode = false -- don't show the mode we are in (such as '--INSERT--')
vim.o.numberwidth = 1 -- minimum line number column width
vim.o.listchars = "tab:▸ ,eol:↲" -- how to display tabs and carriage returns
vim.o.clipboard = 'unnamedplus' -- copy/paste to/from clipboard provider (xclip, pbcopy, etc.)
vim.o.cursorline = true -- highlight line cursor is currently on
vim.o.timeoutlen = 700 -- time in milliseconds while the next mapping key is waited for

-- Windows
vim.o.splitbelow = false -- force horizontal splits to go above the current window
vim.o.splitright = true  -- force vertical splits to go to the right of the current window

-- Search
vim.o.ignorecase = true -- case insensitive by default
vim.o.smartcase = true  -- become case sensitive if a captial letter is typed
vim.o.wrapscan = false  -- don't go back to first match after the last match is found.

-- Tab key and character handling
vim.o.expandtab = true -- tab transformed in spaces
vim.o.tabstop = 2      -- tab correspond to x spaces and vice-versa depending on whether expandtab is on
vim.o.softtabstop = 2  -- column offset when PRESSING the tab key (or the backspace key around spaces)
vim.o.shiftwidth = 2   -- column offset when using keys '>' and '<' in normal mode

-- Disable diagnostics by default
vim.diagnostic.enable(false)
