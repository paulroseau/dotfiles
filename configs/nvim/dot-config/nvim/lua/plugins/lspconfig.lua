local lspconfig = require('lspconfig')

lspconfig.clangd.setup({})

lspconfig.lua_ls.setup({
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
            library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      }

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
})
