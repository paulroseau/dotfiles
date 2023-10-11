require("settings")
require("mappings")

local utils = require("utils")
utils.add_child_directories_to_rtp(vim.fs.normalize("~/.nix-profile/share/neovim-plugins"))
utils.add_child_directories_to_rtp(vim.fs.normalize(vim.fn.stdpath("config") .. "/my-plugins"))

require("plugins.comment")
require("plugins.fzf-lua")
require("plugins.lualine")
require("plugins.neo-tree")
require("plugins.nvim-surround")
require("plugins.nvim-tmux")
require("plugins.nvim-treesitter")
