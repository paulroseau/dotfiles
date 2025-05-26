local M = {}

local DEFAULT_CONFIG = {
  vim_mode_hook_id = 10, -- picked randomly, easiest way to add and remove one particular hook
}

local function get_tmux_option_value(flag_name)
  local function first_line(s)
    local i, _ = string.find(s, "\n")
    return string.sub(s, 1, i - 1)
  end

  local command = vim.system({ 'tmux', 'display-message', '-p', '#{' .. flag_name .. '}'})
  local output = command:wait().stdout
  return first_line(output)
end

local function set_tmux_pane_option(pane_id, option_name, option_value)
  local command = vim.system({ 'tmux', 'set-option', '-t', pane_id, '-p', option_name, option_value })
  command:wait()
end

local function unset_tmux_pane_option(pane_id, option_name)
  local command = vim.system({ 'tmux', 'set-option', '-t', pane_id, '-up', option_name, '' })
  command:wait()
end

local Direction = {
  h = { tmux_edge = "pane_at_left", tmux_flag = "-L", },
  j = { tmux_edge = "pane_at_bottom", tmux_flag = "-D", },
  k = { tmux_edge = "pane_at_top", tmux_flag = "-U", },
  l = { tmux_edge = "pane_at_right", tmux_flag = "-R", },
}

function M.client(_config)
  local client = {}

  if not vim.env.TMUX then
      return nil
  end

  local config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, _config or {})

  local tmux_vim_option_name = vim.env.vim_mode_option
  if not tmux_vim_option_name then
    vim.notify_once("Running in tmux but no 'vim_mode_option' enviornment variable is defined, no smart window navigation", vim.log.levels.WARN)
    return nil
  end

  local pane_id = get_tmux_option_value("pane_id")

  local function set_vim_mode_hook_on_current_pane()
    local option_name = 'pane-focus-in[' .. config.vim_mode_hook_id .. ']'
    local option_value = "set-option -p " .. tmux_vim_option_name .. " \"on\""
    set_tmux_pane_option(pane_id, option_name, option_value)
  end

  local function unset_vim_mode_hook_on_current_pane()
    local option_name = 'pane-focus-in[' .. config.vim_mode_hook_id .. ']'
    unset_tmux_pane_option(pane_id, option_name)
  end

  function client.set_nvim_running_mode()
    set_vim_mode_hook_on_current_pane()
    set_tmux_pane_option(pane_id, tmux_vim_option_name, 'on')
  end

  function client.unset_nvim_running_mode()
    unset_vim_mode_hook_on_current_pane()
    set_tmux_pane_option(pane_id, tmux_vim_option_name, 'off')
  end

  function client.is_current_pane_zoomed()
    return tonumber(get_tmux_option_value("window_zoomed_flag")) == 1
  end

  function client.is_current_pane_on_edge(nvim_key)
    return tonumber(get_tmux_option_value(Direction[nvim_key].tmux_edge)) == 1
  end

  function client.move_pane(nvim_key)
    local command = vim.system({ 'tmux', 'select-pane', Direction[nvim_key].tmux_flag })
    command:wait()
  end

  return client
end

return M
