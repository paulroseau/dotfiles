-- General
vim.o.textwidth = 80                       -- lines length limit (0 if no limit)
vim.o.showmatch = true                     -- shows matching parenthesis
vim.o.matchtime = 2                        -- time during which the matching parenthesis is shown
vim.o.linebreak = true                     -- don't cut lines in the middle of a word
vim.o.number = true                        -- show line numbers
vim.o.numberwidth = 1                      -- minimum line number column width
vim.opt.listchars = "tab:▸ ,eol:↲"
vim.o.clipboard = 'unnamedplus'            -- copy/paste to/from clipboard provider (xclip, pbcopy, etc.)
vim.o.cursorline = true                    -- highlight line cursor is currently on
vim.opt.completeopt:append { "noinsert" }    -- select the first item of popup menu automatically without inserting it

---- Search
vim.o.ignorecase = true -- case insensitive by default
vim.o.smartcase = true  -- become case sensitive if a captial letter is typed
vim.o.wrapscan = false  -- don't go back to first match after the last match is found.

---- Tab key and character handling
vim.o.expandtab = true    -- tab transformed in spaces
vim.o.tabstop = 2         -- tab correspond to x spaces and vice-versa depending on whether expandtab is on
vim.o.softtabstop = 2     -- column offset when PRESSING the tab key (or the backspace key around spaces)
vim.o.shiftwidth = 2      -- column offset when using keys '>' and '<' in normal mode
