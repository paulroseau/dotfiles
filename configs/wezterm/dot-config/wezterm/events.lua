local wezterm = require('wezterm')

local M = {}

M.pane_focused_out = 'pane-focused-out'

function M.act_then_fire_focused_out_event(action)
  return wezterm.action_callback(function(window, pane, _)
    local current_pane_id = pane:pane_id()

    local fire_pane_focused_out_event = wezterm.action_callback(function(window, new_pane, _)
      if new_pane:pane_id() ~= current_pane_id then
        window:perform_action(wezterm.action.EmitEvent(M.pane_focused_out), new_pane)
      end
    end)

    window:perform_action(action, pane)
    window:perform_action(fire_pane_focused_out_event, pane)
  end)
end

return M
