-- This configuration is empty on purpose since this should be configured through vim.g.rustaceanvim
-- This file exist only to allow the rust-analyzer lsp configuration to inherit from settings set on vim.lsp.config['*']

-- Explanaion: rustaceanvim does look up vim.lsp.config['rust-analyzer'] as a base for lsp server configuration.
-- If you check vim.lsp.config.__index defined in share/nvim/runtime/lua/vim/lsp.lua you can see that
-- if this file does not exist (rtp config) or we don't set vim.lsp.config('rust-analyzer', {}) manually,
-- then vim.lsp.config['rust-analyzer'] returns `nil`.
-- However we want it to inherit from vim.lsp.config['*'].
return {}
