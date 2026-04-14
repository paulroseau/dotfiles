local term_group = vim.api.nvim_create_augroup('TerminalConfig', { clear = true })

require('autocommands.terminal').create(term_group)
