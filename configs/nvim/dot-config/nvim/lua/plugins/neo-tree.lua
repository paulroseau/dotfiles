-- Check if this does not make its way into the plugin: https://github.com/nvim-neo-tree/neo-tree.nvim/issues/777

local function open_all_subnodes(state)
  local node = state.tree:get_node()
	local filesystem_commands = require("neo-tree.sources.filesystem.commands")
	filesystem_commands.expand_all_nodes(state, node)
end

require("neo-tree").setup({
  default_component_configs = {
    symlink_target = {
      enabled = true,
    },
  },
  window = {
    mappings = {
      ["<leader>m"] = "cancel",
      ["o"] = "open_drop",
      ["T"] = "open_tab_drop",
      ["O"] = open_all_subnodes,
      ["<M-s>"] = "open_split",
      ["<M-v>"] = "open_vsplit",
      ["<M-p>"] = "toggle_preview",
      ["I"] = "toggle_hidden",
      ["x"] = "close_node",
      ["X"] = "close_all_subnodes",
      ["Y"] = "copy_to_clipboard",
      ["D"] = "cut_to_clipboard",
      ["z"] = "close_all_nodes",
      ["Z"] = "expand_all_nodes",
      ["P"] = "paste_from_clipboard",
      ["p"] = "paste_from_clipboard",
      ["i"] = "noop",
      ["y"] = "noop",
      ["w"] = "noop",
      ["/"] = "noop",
      ["H"] = "noop",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["u"] = "navigate_up",
        ["F"] = "fuzzy_finder",
        ["<BS>"] = "noop",
      },
      fuzzy_finder_mappings = {
        ["<C-k>"] = "move_cursor_up",
        ["<C-j>"] = "move_cursor_down",
        ["<up>"] = "move_cursor_up",
        ["<down>"] = "move_cursor_down",
      },
    }
  },
})

vim.keymap.set({'n'} , '<leader>x', '<cmd>Neotree toggle<CR>')
vim.keymap.set({'n'} , '<leader>r', '<cmd>Neotree reveal<CR>')
