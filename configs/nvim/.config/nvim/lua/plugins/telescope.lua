local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
          
require("telescope").setup({
  defaults = {
    file_ignore_patterns = {
      "^%.git/", -- because we want to search through hidden files
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        -- Neotree style mappings for split opening and preview
        ["<C-s>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions_layout.toggle_preview,

        -- Partial Emacs style mappings (no <C-y> and no <C-k> cf. above)
        ["<C-b>"] = { "<Left>", type = "command" },
        ["<C-f>"] = { "<Right>", type = "command" },
        ["<M-b>"] = { "<S-Left>", type = "command" },
        ["<M-f>"] = { "<S-Right>", type = "command" },
        ["<C-a>"] = { "<Home>", type = "command" },
        ["<C-e>"] = { "<End>", type = "command" },
        ["<C-d>"] = { "<Del>", type = "command" },
        ["<M-BS>"] = { "<Esc>BcW", type = "command" },
        ["<M-d>"] = { " <Esc>cE", type = "command" },
        ["<C-u>"] = { "<C-u>", type = "command" },
      },
      n = {
        ["<C-c>"] = actions.close,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions_layout.toggle_preview,
        ["q"] = actions.close,
      },
    },
  },
  pickers = {
    find_files = {
      preview = {
        hide_on_startup = true,
      },
      follow = true,
      hidden = true,
    },

    live_grep = {
      follow = true,
      hidden = true,
    },

    builtin = {
      preview = {
        hide_on_startup = true,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  }
})

vim.keymap.set({'n'} , '<leader>tt', require("telescope.builtin").builtin)
vim.keymap.set({'n'} , '<leader>tf', require("telescope.builtin").find_files)
vim.keymap.set({'n'} , '<leader>tl', require("telescope.builtin").live_grep)
vim.keymap.set({'n'} , '<leader>tL', require("telescope.builtin").current_buffer_fuzzy_find)
vim.keymap.set({'n'} , '<leader>tb', require("telescope.builtin").buffers)
vim.keymap.set({'n'} , '<leader>th', require("telescope.builtin").help_tags)

require('telescope').load_extension('fzf')
