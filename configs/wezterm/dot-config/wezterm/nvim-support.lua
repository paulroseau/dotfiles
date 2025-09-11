local wezterm = require('wezterm')
local events = require('events')

local M = {}

local NVIM_RUNNING_USER_VAR = "is_nvim_running"

local DO_IGNORE_NVIM_RUNNING_USER_VAR = false

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

function M.do_pass_keys_to_nvim(pane_user_vars)
  return pane_user_vars[NVIM_RUNNING_USER_VAR] == "true" and not DO_IGNORE_NVIM_RUNNING_USER_VAR
end

function M.assign_key(args)
  return send_keys_or_else(
    function(window, pane)
      return M.do_pass_keys_to_nvim(pane:get_user_vars())
    end,
    args.key,
    args.mods,
    args.action
  )
end

M.toggle_ignore_nvim_running_flag = wezterm.action_callback(function(window, pane)
  DO_IGNORE_NVIM_RUNNING_USER_VAR = not DO_IGNORE_NVIM_RUNNING_USER_VAR
end)

local function reset_ignore_nvim_running_flag()
  DO_IGNORE_NVIM_RUNNING_USER_VAR = false
end

function M.set_on_pane_focused_in_handler()
  wezterm.on(events.pane_focused_out, function(window, pane)
    reset_ignore_nvim_running_flag()
  end)
end

return M
