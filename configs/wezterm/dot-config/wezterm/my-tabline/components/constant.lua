local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(text, icon)
  return component.new(text, icon)
end

return {
  for_window = function(window, pane, extra) return make(extra.text, extra.icon) end,
  for_tab = function(tab_info, extra) return make(extra.text, extra.icon) end
}
