local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(window)
  local window_title = window:mux_window():get_title()
  local text = (window_title == '' and 'default') or window_title
  return component.new(text)
end

return {
  window = make,
  tab = function(tab_info)
    local window = wezterm.mux.get_window(tab_info.window_id)
    return make(window)
  end
}
