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
			init_selection = "<M-}>",
			node_incremental = "<M-}>",
			node_decremental = "<M-{>",
		},
  },

  indent = {
    enable = true,
  },
}

vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
