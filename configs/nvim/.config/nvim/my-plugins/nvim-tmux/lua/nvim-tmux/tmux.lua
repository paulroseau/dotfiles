local M = {}

local function get_tmux_option_value(flag_name)
  local pipe = io.popen("tmux display-message -p \"#{" .. flag_name .. "}\"")
  local result = pipe:read("*number")
  pipe:close()
  return result
end

function M.client(config)
  local TmuxClient = {}

  function TmuxClient.set_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -p pane-focus-in[" .. config.vim_mode_hook_id .. "] 'set-option -w " .. config.vim_option_name .. " \"on\"'")
  end

  function TmuxClient.unset_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -up pane-focus-in[" .. config.vim_mode_hook_id .. "]")
  end

  function TmuxClient.set_vim_mode(option_value)
    return os.execute("tmux set-option -w " .. config.vim_option_name .. " \"" .. option_value .. "\"")
  end

  function TmuxClient.is_current_window_zoomed()
    return get_tmux_option_value("window_zoomed_flag") == 1
  end

  function TmuxClient.is_current_pane_at(at_edge)
    return get_tmux_option_value(at_edge) == 1
  end

  function TmuxClient.select_pane(flag)
    return os.execute("tmux select-pane " .. flag)
  end

  return TmuxClient
end

return M
