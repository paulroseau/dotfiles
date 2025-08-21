local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(window_title)
  local text = (window_title == '' and 'default') or window_title
  return component.new(text)
end

return {
  for_window = function(args) return make(args.window:mux_window():get_title()) end,
  for_tab = function(args) return make(args.tab_info.window_title) end
}
