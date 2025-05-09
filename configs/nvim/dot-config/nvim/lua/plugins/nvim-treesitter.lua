local nvim_treesitter_configs = require('nvim-treesitter.configs')

local ensure_installed = {
  "bash", 
  "c", 
  "dockerfile",
  "go",
  "haskell",
  "hcl",
  "json",
  "lua",
  "markdown",
  "nix",
  "ocaml",
  "python",
  "query",
  "rust",
  "scala",
  "vim",
  "vimdoc",
  "yaml",
  -- "zsh"  not supported by nvim-treesitter yet, even though the grammar is available https://github.com/tree-sitter-grammars/tree-sitter-zsh
}

local nvim_treesitter_source = debug.getinfo(nvim_treesitter_configs.setup).source
if string.find(nvim_treesitter_source, ".nix-profile/", 1, true) then
  -- Setting ensure_installed to a non nil value causes 
  -- nvim-treesitter to first check that the parser_install_dir is
  -- writable, which is not the case when installed through nix...
  ensure_installed = nil
end

nvim_treesitter_configs.setup {
  ensure_installed = ensure_installed,
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
