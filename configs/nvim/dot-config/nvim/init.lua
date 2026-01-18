-- General settings
require('settings')
require('mappings')
require('commands')
require('treesitter')
require('lsp')

-- Add personal (vendored) plugins to RTP
local utils = require('utils')
utils.add_child_directories_to_rtp(vim.fs.normalize(vim.fn.stdpath('config') .. '/my-plugins'))

-- Configure plugins
require('plugins.blink-cmp')
require('plugins.codecompanion')
require('plugins.conform')
require('plugins.comment')
require('plugins.flatten')
require('plugins.fugitive')
require('plugins.fzf-lua')
require('plugins.lazydev')
require('plugins.lualine')
require('plugins.luatab')
require('plugins.minipairs')
require('plugins.neo-tree')
require('plugins.nvim-resize-window')
require('plugins.nvim-surround')
require('plugins.nvim-tmux')
require('plugins.nvim-wezterm')
require('plugins.render-markdown')
require('plugins.rustaceanvim')
require('plugins.toggleterm')
require('plugins.wildfire')
require('plugins.zen-mode')

-- nvim-treesitter needs to be loaded if TS parsers are not managed by nix
if pcall(require, 'nvim-treesitter') then
  require('plugins.nvim-treesitter')
end

-- Configure colorscheme plugins
require('plugins.colorschemes.nord')
require('plugins.colorschemes.solarized')
require('plugins.colorschemes.tokyonight')

-- Pick default colorscheme
vim.cmd.colorscheme('nightfox')
