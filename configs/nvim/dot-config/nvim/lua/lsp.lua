-- Configs are in ./nvim-lspconfig/lua/lsp folder
-- Since ./nvim-lspconfig is in the RTP, `vim.lsp.enable` works out of the box without needing to explicitly require('lspconfig')
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls') -- TODO include vim.env as library when relevant
vim.lsp.enable('jsonls')
vim.lsp.enable('nil_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('rust-analyzer')
vim.lsp.enable('terraformls')

vim.lsp.config('*', {
  on_attach = function(client, bufnr)
    if client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end
})
