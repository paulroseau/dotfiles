local function toggle_diagnostic()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end

vim.api.nvim_create_user_command('DiagnosticToggle', toggle_diagnostic, {})
vim.api.nvim_create_user_command('DiagnosticEnable', function () vim.diagnostic.enable() end, {})
vim.api.nvim_create_user_command('DiagnosticDisable', function () vim.diagnostic.disable() end, {})
