local wezterm = require('wezterm')
local events = require('events')
local utils = require('utils')
local act = wezterm.action

local function choices(current_window)
  local workspaces = {}

  for _, window in pairs(wezterm.mux.all_windows()) do
    local workspace = window:get_workspace()
    workspaces[workspace] = false
  end

  local current_workspace = current_window:mux_window():get_workspace()
  workspaces[current_workspace] = true

  local choices = {}

  for workspace, is_current in pairs(workspaces) do
    if not is_current then
      table.insert(choices, { label = workspace, id = workspace })
    end
  end
  table.sort(choices, function(a, b) return a.label < b.label end)
  table.insert(choices, 1, { label = current_workspace .. ' (active)', id = nil })

  return choices
end

local action = wezterm.action_callback(function(window, pane, id, label)
  if id then
    window:perform_action(
      events.act_then_fire_focused_out_event(act.SwitchToWorkspace { name = id }),
      pane
    )
  end
end
)

return wezterm.action_callback(function(window, pane, _)
  window:perform_action(act.InputSelector {
      title = 'Workspace Selector',
      choices = choices(window),
      action = action,
      fuzzy = true,
      description = 'Select workspace: ',
      fuzzy_description = 'Select workspace: ',
    },
    pane
  )
end)
