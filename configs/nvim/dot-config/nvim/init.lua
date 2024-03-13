-- General settings
require("settings")
require("mappings")
require("commands")

-- Add plugins to runtimepath
local utils = require("utils")
utils.add_child_directories_to_rtp(vim.fs.normalize("~/.nix-profile/share/neovim-plugins"))
utils.add_child_directories_to_rtp(vim.fs.normalize(vim.fn.stdpath("config") .. "/my-plugins"))

-- Configure plugins
require("plugins.comment")
require("plugins.flatten")
require("plugins.fugitive")
require("plugins.fzf-lua")
require("plugins.lualine")
require("plugins.neo-tree")
require("plugins.nvim-surround")
require("plugins.nvim-tmux")
require("plugins.nvim-treesitter")
require("plugins.onedark")
require("plugins.tokyonight")
require("plugins.toggleterm")
require("plugins.nvim-cmp")
require("plugins.lspconfig")

-- Pick colorscheme
vim.cmd.colorscheme("tokyonight")
