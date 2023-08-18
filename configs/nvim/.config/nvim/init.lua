require("settings")
require("mappings")
require("nvim-in-tmux").setup()

local utils = require("utils")
utils.add_child_directories_to_rtp(vim.fs.normalize("~/.nix-profile/share/neovim-plugins"))

require("plugins.lualine")
require("plugins.nvim-treesitter")
require("plugins.neo-tree")
require("plugins.comment")
require("plugins.nvim-surround")
