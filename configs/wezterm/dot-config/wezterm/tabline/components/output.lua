local wezterm = require('wezterm')
local component = require('tabline.component')
local utils = require('utils')

local function make(panes_unseen_output)
  local icon = nil
  for _, unseen_output in ipairs(panes_unseen_output) do
    if unseen_output then
      icon = wezterm.nerdfonts.md_bell_badge_outline
      return component.new(nil, icon)
    end
  end
  return component.new(nil, icon)
end

return {
  for_window = function(gui_window, pane)
    local tabs = gui_window:mux_window():tabs()
    local all_panes = utils.flatten(
      utils.map(tabs, function(tabs) return tabs:panes() end),
      nil
    )
    local unseen_outputs = utils.map(
      all_panes,
      function(pane) return pane:has_unseen_output() end
    )
    return make(unseen_outputs)
  end,
  for_tab = function(tab_info)
    local unseen_outputs = utils.map(
      tab_info.panes,
      function(pane_info) return pane_info.has_unseen_output end
    )
    return make(unseen_outputs)
  end
}
