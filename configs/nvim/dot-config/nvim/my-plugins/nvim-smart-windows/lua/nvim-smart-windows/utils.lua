local M = {}

function M.setup_augroup(augroup_name, client)
  local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

  vim.api.nvim_create_autocmd({'VimEnter', 'VimResume'}, {
    callback = client.set_nvim_running_flag,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({'VimLeave', 'VimSuspend'}, {
    callback = client.unset_nvim_running_flag,
    group = augroup,
  })

  return augroup
end

local allowed_nvim_keys = { h = {}, j = {}, k = {}, l = {}, }

function M.setup_commands(config, client)

  local change_nvim_window = function(opts)
    local nvim_key = opts.fargs[1]
    if not allowed_nvim_keys[nvim_key] then
      return
    end

    local start_window = vim.fn.winnr()
    vim.cmd.wincmd(nvim_key)
    local end_window = vim.fn.winnr()

    if end_window ~= start_window then
      return
    elseif client.is_current_pane_zoomed() and config.do_preserve_zoomed_pane then
      return
    end

    client.move_pane(nvim_key)
  end

  vim.api.nvim_create_user_command(
    config.command_prefix .. 'Wincmd', 
    change_nvim_window,
    { nargs = 1 }
  )

  vim.api.nvim_create_user_command(
    config.command_prefix .. 'Toggle', 
    client.toggle_nvim_running_flag,
    {}
  )
end

return M
