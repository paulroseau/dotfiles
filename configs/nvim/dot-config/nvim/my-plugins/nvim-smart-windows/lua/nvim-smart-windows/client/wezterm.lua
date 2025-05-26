local M = {}

local DEFAULT_CONFIG = {
  nvim_wezterm_user_var = 'is_nvim_running'
}

local function set_wezterm_user_var(key, value)
  io.write(vim.fn.printf("\x1b]1337;SetUserVar=%s=%s\a", key, vim.base64.encode(value)))
end

local Direction = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

function M.client(_config)
  if vim.env.TERM_PROGRAM ~= 'WezTerm' then
    return nil
  end

  local client = {}

  local config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, _config or {})

  local state = true

  local function update_nvim_wezterm_user_var(value)
    state = value
    set_wezterm_user_var(config.nvim_wezterm_user_var, tostring(state))
  end

  function client.set_nvim_running_mode()
    update_nvim_wezterm_user_var(true)
  end

  function client.unset_nvim_running_mode()
    update_nvim_wezterm_user_var(false)
  end

  function client.is_current_pane_zoomed()
    -- not handling if from here, we set unzoom_on_switch_pane in wezterm config
    return false
  end

  function client.is_current_pane_on_edge(nvim_key)
    -- Wezterm prevents wrapping around panes by default
    return false
  end

  function client.move_pane(nvim_key)
    vim.system({ 'wezterm', 'cli', 'activate-pane-direction', Direction[nvim_key] })
  end

  return client
end

return M
