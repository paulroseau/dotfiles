require("settings")
require("mappings")
require("nvim-in-tmux").setup()

local utils = require("utils")
utils.add_child_directories_to_rtp(vim.fs.normalize("~/.nix-profile/share/neovim-plugins"))

require('lualine').setup()

require('nvim-treesitter.configs').setup {
  -- Don't install anything through nvim-treesitter plugin,
  -- parsers are compiled and added to the rtp with nix
  ensure_installed = {},
  auto_install = false,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-k>",
      node_incremental = "<C-k>",
      node_decremental = "<C-j>",
      scope_incremental = "<C-K>",
    },
  },

  indent = {
    enable = true,
  },
}

vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

require("neo-tree").setup({
  window = {
    mappings = {
      ["<leader>m"] = "cancel",
      ["o"] = "open_drop",
      ["T"] = "open_tab_drop",
      ["I"] = "toggle_hidden",
      ["w"] = "open_with_window_picker",
      ["x"] = "close_node",
      ["X"] = 'close_all_subnodes',
      ["z"] = "close_all_nodes",
      ["Z"] = "expand_all_nodes",
      ["C"] = "cut_to_clipboard",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["u"] = "navigate_up",
        ["<C-/>"] = "fuzzy_finder",
      },
      fuzzy_finder_mappings = {
        ["<C-k>"] = "move_cursor_up",
        ["<C-j>"] = "move_cursor_down",
        ["<up>"] = "move_cursor_up",
        ["<down>"] = "move_cursor_down",
      },
    }
  },
  buffers = {
    window = {
      mappings = {
        ["u"] = "navigate_up",
      }
    }
  }
})

vim.keymap.set({'n'} , '<leader>t', '<cmd>Neotree toggle<CR>')
