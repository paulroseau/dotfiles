local wezterm = require('wezterm')
local component = require('my-tabline.component')
local utils = require('my-tabline.utils')

local function make(panes_is_zoomed)
  local icon = nil
  for _, is_zoomed in ipairs(panes_is_zoomed) do
    if is_zoomed then
      icon = wezterm.nerdfonts.oct_zoom_in
      return component.new(nil, icon)
    end
  end
  return component.new(nil, icon)
end

return {
  for_window = function(gui_window, pane)
    local panes_with_info = gui_window:active_tab():panes_with_info()
    local unseen_outputs = utils.map(
      panes_with_info,
      function(info) return info.is_zoomed end
    )
    return make(unseen_outputs)
  end,
  for_tab = function(tab_info)
    local unseen_outputs = utils.map(
      tab_info.panes,
      function(pane_info) return pane_info.is_zoomed end
    )
    return make(unseen_outputs)
  end
}
