local lspconfig = require('lspconfig')

-- From README of https://github.com/hrsh7th/cmp-nvim-lsp
-- nvim-cmp supports more types of completion candidates, so users must override
-- the LSP client's capabilities sent to the server such that it can provide
-- these candidates during a completion request.
-- lspconfig initializes clients with a default config based of
-- lsp.protocol.make_client_capabilities() (cf. lspconfig/util.lua) and
-- merges it with what we pass in arguments (cf. use of
-- vim.tbl_deep_extend('keep', ...))
local lsp_client_extra_capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.clangd.setup({
  capabilities = lsp_client_extra_capabilities,
})

lspconfig.lua_ls.setup({
  capabilities = lsp_client_extra_capabilities,

  -- Update the client settings if no file configuring the LSP server to include
  -- all RTP paths in the context
  -- We update the client.config.setting so those changes are sent to the LSP
  -- server if it sends a workspace/configuration request to the client later on
  -- We force the server to update by sending a notification workspace/didChangeConfiguration
  -- We are using on_init to be able to look up the client and find the path of the workspace folder
  -- where the configuration might be, otherwise a simpler approach would be to
  -- just pass the settings parameter directly to the setup function
  
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      client.config.settings = {
        Lua = {
          workspace = {
            library = { vim.env.VIMRUNTIME },
          }
        }
      }

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
})

lspconfig.pyright.setup({
  capabilities = lsp_client_extra_capabilities,
})

lspconfig.rust_analyzer.setup({
  capabilities = lsp_client_extra_capabilities,
})
