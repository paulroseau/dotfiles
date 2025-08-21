local component = require('my-tabline.component')
local config = require('my-tabline.config')

local function make(zero_based_active_tab_index)
  local tab_index = config.zero_based_tabs_index and zero_based_active_tab_index or zero_based_active_tab_index + 1
  return component.new(tostring(tab_index))
end

return {
  for_window = function(args)
    local tabs_with_info = args.window:mux_window():tabs_with_info()
    local active_tab_index = -1
    for _, tab_info in ipairs(tabs_with_info) do
      if tab_info.is_active then
        active_tab_index = tab_info.index
        break
      end
    end
    return make(active_tab_index)
  end,
  for_tab = function(args)
    return make(args.tab_info.tab_index)
  end
}
