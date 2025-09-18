-- General settings
require('settings')
require('mappings')
require('commands')
require('lsp').configure()

-- Add plugins to runtimepath
local utils = require('utils')
utils.add_child_directories_to_rtp(vim.fs.normalize(vim.fn.stdpath('config') .. '/my-plugins'))
utils.add_child_directories_to_rtp(vim.fs.normalize('$NVIM_PLUGINS_DIR'))

-- Configure plugins
require('plugins.nvim-tmux')
require('plugins.nvim-wezterm')
require('plugins.nvim-resize-window')
require('plugins.codecompanion')
require('plugins.comment')
require('plugins.flatten')
require('plugins.fugitive')
require('plugins.fzf-lua')
require('plugins.lualine')
require('plugins.neo-tree')
require('plugins.nvim-surround')
require('plugins.nvim-treesitter')
require('plugins.toggleterm')
require('plugins.blink-cmp')
require('plugins.lazydev')
require('plugins.luatab')
require('plugins.rustaceanvim')
require('plugins.minipairs')
require('plugins.zen-mode')

-- Pick colorscheme
require('plugins.colorschemes.nord')
require('plugins.colorschemes.onedark')
require('plugins.colorschemes.solarized')
require('plugins.colorschemes.tokyonight')
vim.cmd.colorscheme('tokyonight')
