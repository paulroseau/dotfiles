vim.api.nvim_create_user_command('DiagnosticToggle',
  function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, {}
)

vim.api.nvim_create_user_command('LspInfo', function() vim.cmd.checkhealth('vim.lsp') end, {})
vim.api.nvim_create_user_command('LspStopAll', function() vim.lsp.stop_client(vim.lsp.get_clients()) end, {})
