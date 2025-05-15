local M = {}

local function get_tmux_option_value(flag_name, type)
  local pipe = io.popen("tmux display-message -p \"#{" .. flag_name .. "}\"")
  local result = pipe:read(type)
  pipe:close()
  return result
end

function M.client(config)
  local TmuxClient = {}

  local pane_id = get_tmux_option_value("pane_id", "*line")

  function TmuxClient.set_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -t " .. pane_id .. " -p pane-focus-in[" .. config.vim_mode_hook_id .. "] 'set-option -p " .. config.vim_option_name .. " \"on\"'")
  end

  function TmuxClient.unset_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -t " .. pane_id .. " -up pane-focus-in[" .. config.vim_mode_hook_id .. "]")
  end

  function TmuxClient.set_vim_mode(option_value)
    return os.execute("tmux set-option -t " .. pane_id .. " -p " .. config.vim_option_name .. " \"" .. option_value .. "\"")
  end

  function TmuxClient.is_current_window_zoomed()
    return get_tmux_option_value("window_zoomed_flag", "*number") == 1
  end

  function TmuxClient.is_current_pane_at(at_edge)
    return get_tmux_option_value(at_edge, "*number") == 1
  end

  function TmuxClient.select_pane(flag)
    return os.execute("tmux select-pane " .. flag)
  end

  return TmuxClient
end

return M
