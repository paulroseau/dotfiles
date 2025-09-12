local component = require('tabline.component')
local config = require('tabline.config')

local function make(zero_based_active_tab_index)
  local tab_index = config.zero_based_tabs_index and zero_based_active_tab_index or zero_based_active_tab_index + 1
  return component.new(tostring(tab_index))
end

return {
  for_window = function(gui_window, pane)
    local tabs_with_info = gui_window:mux_window():tabs_with_info()
    local active_tab_index = -1
    for _, tab_info in ipairs(tabs_with_info) do
      if tab_info.is_active then
        active_tab_index = tab_info.index
        break
      end
    end
    return make(active_tab_index)
  end,
  for_tab = function(tab_info)
    return make(tab_info.tab_index)
  end
}
