local M = {}

M.setup_auto_formatting_on_save = function(client, bufnr)
  if client:supports_method('textDocument/formatting') then
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
      end,
    })
  end
end

M.configure = function()
  vim.lsp.config('*', {
    on_attach = function(client, bufnr)
      M.setup_auto_formatting_on_save(client, bufnr)
    end
  })

  vim.lsp.enable('clangd')
  vim.lsp.enable('lua_ls')
  vim.lsp.enable('jsonls')
  vim.lsp.enable('nil_ls')
  vim.lsp.enable('pyright')
  vim.lsp.enable('terraformls')
  vim.lsp.enable('yaml_ls')
end

return M
