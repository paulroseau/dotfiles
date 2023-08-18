require("neo-tree").setup({
  window = {
    mappings = {
      ["<leader>m"] = "cancel",
      ["o"] = "open_drop",
      ["T"] = "open_tab_drop",
      ["i"] = "open_split",
      ["s"] = "open_vsplit",
      ["I"] = "toggle_hidden",
      ["w"] = "noop",
      ["x"] = "close_node",
      ["X"] = "close_all_subnodes",
      ["y"] = "copy_to_clipboard",
      ["c"] = "cut_to_clipboard",
      ["z"] = "close_all_nodes",
      ["Z"] = "expand_all_nodes",
      ["C"] = "copy",
      ["/"] = "noop",
      ["H"] = "noop",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["u"] = "navigate_up",
        ["F"] = "fuzzy_finder",
        ["D"] = "fuzzy_finder_directory",
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
vim.keymap.set({'n'} , '<leader>f', '<cmd>Neotree reveal<CR>')
