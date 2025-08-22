local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(args)
  return component.new(args.text)
end

return {
  for_window = function(gui_window, pane) return make end,
  for_tab = function(tab_info) return make end
}
