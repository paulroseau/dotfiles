local M = {}

local wezterm = require('wezterm')

local NVIM_RUNNING_USER_VAR = "is_nvim_running"

local function send_keys_or_else(predicate, key, mods, fallback_action)
  local action = wezterm.action_callback(function(window, pane, _)
    if predicate(window, pane) then
      window:perform_action(wezterm.action.SendKey { key = key, mods = mods }, pane)
    else
      window:perform_action(fallback_action, pane)
    end
  end)
  return { key = key, mods = mods, action = action }
end

function M.assign_key(args)
  local is_nvim_running = function(window, pane)
    return pane:get_user_vars()[NVIM_RUNNING_USER_VAR] == "true"
  end

  return send_keys_or_else(is_nvim_running, args.key, args.mods, args.action)
end

return M
