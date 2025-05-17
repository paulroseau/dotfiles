local M = {}

function M.setup_augroup(augroup_name, client)
  local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

  vim.api.nvim_create_autocmd({'VimEnter', 'VimResume'}, {
    callback = client.set_nvim_running_mode,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({'VimLeave', 'VimSuspend'}, {
    callback = client.unset_nvim_running_mode,
    group = augroup,
  })

  return augroup
end

local direction = { h = "Left", j = "Down", k = "Up", l = "Right", }

local function create_command(config, client, nvim_key)
  local change_nvim_window = function(opts)
    local start_window = vim.fn.winnr()
    vim.cmd.wincmd(nvim_key)
    local end_window = vim.fn.winnr()

    if end_window ~= start_window then
      return
    elseif client.is_current_pane_zoomed() and config.do_preserve_zoomed_pane then
      return
    elseif client.is_current_pane_on_edge(nvim_key) then
      return
    end

    client.move_pane(nvim_key)
  end

  vim.api.nvim_create_user_command(
    config.command_prefix .. 'Wincmd' .. direction[nvim_key], 
    change_nvim_window,
    { }
  )
end

function M.setup_commands(config, client)
  create_command(config, client, 'h')
  create_command(config, client, 'j')
  create_command(config, client, 'k')
  create_command(config, client, 'l')
end

return M
