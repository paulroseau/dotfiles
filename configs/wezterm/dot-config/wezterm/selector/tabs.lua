local wezterm = require('wezterm')
local events = require('events')
local utils = require('utils')
local act = wezterm.action

local function choices(current_window)
  local choices = {}

  local tabs_info = current_window:mux_window():tabs_with_info()
  for _, tab_info in ipairs(tabs_info) do
    table.insert(
      choices,
      {
        label = tab_info.tab:get_title(),
        id = (not tab_info.is_active) and tostring(tab_info.index) or nil
      }
    )
  end

  return choices
end

local action = wezterm.action_callback(function(window, pane, id, label)
  if id then
    window:perform_action(
      events.act_then_fire_focused_out_event(act.ActivateTab(tonumber(id))),
      pane
    )
  end
end
)

return wezterm.action_callback(function(window, pane, _)
  window:perform_action(act.InputSelector {
      title = 'Tab Selector',
      choices = choices(window),
      action = action,
      fuzzy = true,
      description = 'Select tab: ',
      fuzzy_description = 'Select tab: ',
    },
    pane
  )
end)
