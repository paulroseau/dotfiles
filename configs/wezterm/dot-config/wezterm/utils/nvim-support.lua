local M = {}

local wezterm = require('wezterm')

local event = require('utils.event')

local NVIM_RUNNING_USER_VAR = "is_nvim_running"

local DO_IGNORE_NVIM_RUNNING_USER = false

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
    return pane:get_user_vars()[NVIM_RUNNING_USER_VAR] == "true" and not DO_IGNORE_NVIM_RUNNING_USER
  end

  return send_keys_or_else(is_nvim_running, args.key, args.mods, args.action)
end

function M.get_ignore_nvim_running_flag()
  return DO_IGNORE_NVIM_RUNNING_USER
end

function M.toggle_ignore_nvim_running_flag()
  DO_IGNORE_NVIM_RUNNING_USER = not DO_IGNORE_NVIM_RUNNING_USER
end

local function reset_ignore_nvim_running_flag()
  DO_IGNORE_NVIM_RUNNING_USER = false
end

function M.set_on_pane_focused_in_handler()
  wezterm.on(event.pane_focused_in, function(window, pane)
    reset_ignore_nvim_running_flag()
  end)
end

return M
