local wezterm = require('wezterm')
local component = require('my-tabline.component')
local palette = require('my-tabline.palette')

local function make()
  return component.new('N/A', wezterm.nerdfonts.fa_skull, palette.red)
end

return {
  for_window = function(gui_window, pane) return make() end,
  for_tab = function(tab_info) return make() end,
}
