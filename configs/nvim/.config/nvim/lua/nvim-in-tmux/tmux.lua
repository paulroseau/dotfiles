local M = {}

function M.setup(config)
  local Tmux = {}

  local function get_flag_value(flag_name)
    local pipe = io.popen("tmux display-message -p \"#{" .. flag_name .. "}\"")
    local result = pipe:read("*number")
    pipe:close()
    return result
  end

  function Tmux.is_current_window_zoomed()
    return get_flag_value("window_zoomed_flag") == 1
  end

  function Tmux.is_current_pane_at(at_edge)
    return get_flag_value(at_edge) == 1
  end

  function Tmux.set_vim_mode(option_value)
    return os.execute("tmux set-option -w " .. config.vim_option_name .. " \"" .. option_value .. "\"")
  end

  function Tmux.set_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -p pane-focus-in[" .. config.vim_mode_hook_id .. "] 'set-option -w " .. config.vim_option_name .. " \"on\"'")
  end

  function Tmux.unset_vim_mode_hook_on_current_pane()
    return os.execute("tmux set-option -up pane-focus-in[" .. config.vim_mode_hook_id .. "]")
  end

  function Tmux.select_pane(flag)
    return os.execute("tmux select-pane " .. flag)
  end

  return Tmux
end

return M
