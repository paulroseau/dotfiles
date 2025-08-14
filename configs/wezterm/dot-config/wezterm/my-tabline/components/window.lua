local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(window_title)
  local text = (window_title == '' and 'default') or window_title
  return component.new(text)
end

return {
  for_window = function(window, pane) return make(window:mux_window():get_title()) end,
  for_tab = function(tab_info) return make(tab_info.window_title) end
}
