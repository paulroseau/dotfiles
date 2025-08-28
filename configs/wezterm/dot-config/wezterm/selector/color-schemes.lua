local wezterm = require('wezterm')
local act = wezterm.action

local choices = {
  { label = 'tokyo night',         id = 'Tokyo Night' },
  { label = 'tokyo night (day)',   id = 'Tokyo Night Day' },
  { label = 'tokyo night (moon)',  id = 'Tokyo Night Moon' },
  { label = 'tokyo night (storm)', id = 'Tokyo Night Storm' },
  { label = 'one dark',            id = 'One Dark (Gogh)' },
  { label = 'solarized (dark)',    id = 'Solarized (dark) (terminal.sexy)' },
  { label = 'solarized (light)',   id = 'Solarized (light) (terminal.sexy)' },
}

local action = wezterm.action_callback(function(window, pane, id, label)
  if id then
    local config_overrides = window:get_config_overrides() or {}
    config_overrides.color_scheme = id
    window:set_config_overrides(config_overrides)
  end
end)

return wezterm.action_callback(function(window, pane, _)
  window:perform_action(act.InputSelector {
      title = 'Scheme Selector',
      choices = choices,
      action = action,
      fuzzy = true,
      description = 'Select scheme: ',
      fuzzy_description = 'Select scheme: ',
    },
    pane
  )
end)
