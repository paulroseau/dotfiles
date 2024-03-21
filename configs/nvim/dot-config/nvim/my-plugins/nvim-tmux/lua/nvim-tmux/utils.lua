local M = {}

function M.setup_augroup(augroup_name, tmux_client)
  local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

  vim.api.nvim_create_autocmd({'VimEnter', 'VimResume'}, {
    callback = function ()
      tmux_client.set_vim_mode_hook_on_current_pane()
      tmux_client.set_vim_mode("on")
    end,
    group = augroup,
  })

  vim.api.nvim_create_autocmd({'VimLeave', 'VimSuspend'}, {
    callback = function()
      tmux_client.unset_vim_mode_hook_on_current_pane()
      tmux_client.set_vim_mode("off")
    end,
    group = augroup,
  })

  return augroup
end

local Direction = {
  h = { tmux_edge = "pane_at_left", tmux_flag = "-L", },
  j = { tmux_edge = "pane_at_bottom", tmux_flag = "-D", },
  k = { tmux_edge = "pane_at_top", tmux_flag = "-U", },
  l = { tmux_edge = "pane_at_right", tmux_flag = "-R", },
}

function M.setup_commands(config, tmux_client)
  local change_nvim_window = function(opts)
    local vim_key = opts.fargs[1]
    if not Direction[vim_key] then
      return
    end

    local start_window = vim.fn.winnr()
    vim.cmd.wincmd(vim_key)
    local end_window = vim.fn.winnr()

    if end_window ~= start_window then
      return
    elseif tmux_client.is_current_window_zoomed() and config.do_preserve_zoomed_window then
      return
    elseif tmux_client.is_current_pane_at(Direction[vim_key].tmux_edge) then
      return
    end

    tmux_client.select_pane(Direction[vim_key].tmux_flag)
  end

  vim.api.nvim_create_user_command(
    "NvimTmuxWincmd", 
    change_nvim_window,
    { nargs = 1 }
  )
end

return M
