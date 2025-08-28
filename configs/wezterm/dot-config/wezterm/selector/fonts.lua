local wezterm = require('wezterm')
local fonts = require('fonts')
local utils = require('utils')
local act = wezterm.action

local choices = utils.map_key_value(
  fonts.get_available_fonts(),
  function(key, _) return { label = key } end
)
table.sort(choices, function(a, b) return a.label < b.label end)

local action = wezterm.action_callback(function(window, pane, id, label)
  if label then
    local config_overrides = window:get_config_overrides() or {}
    fonts.set_font_if_available(label, config_overrides)
    window:set_config_overrides(config_overrides)
  end
end)

return wezterm.action_callback(function(window, pane, _)
  window:perform_action(act.InputSelector {
      title = 'Font Selector',
      choices = choices,
      action = action,
      fuzzy = true,
      description = 'Select font: ',
      fuzzy_description = 'Select font: ',
    },
    pane
  )
end)
