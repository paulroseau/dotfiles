local wezterm = require('wezterm')
local component = require('my-tabline.component')
local utils = require('my-tabline.utils')

local function make(unseen_outputs)
  local text = nil
  local icon = nil
  for _, unseen_output in ipairs(unseen_outputs) do
    if unseen_output then
      text = '!'
      icon = wezterm.nerdfonts.md_bell_badge_outline
      return component.new(text, icon)
    end
  end
  return component.new(text, icon)
end

return {
  for_window = function(gui_window, pane, extra)
    local panes = gui_window:active_tab():panes()
    local unseen_outputs = utils.map(
      panes,
      function(pane) return pane:has_unseen_output() end
    )
    return make(unseen_outputs, extra)
  end,
  for_tab = function(tab_info)
    local unseen_outputs = utils.map(
      tab_info.panes,
      function(pane_info) return pane_info.has_unseen_output end
    )
    return make(unseen_outputs)
  end
}
