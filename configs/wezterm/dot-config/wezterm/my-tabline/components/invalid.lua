local wezterm = require('wezterm')
local component = require('my-tabline.component')
local palette = require('my-tabline.palette')

local function make(_)
  return component.new('N/A', wezterm.nerdfonts.fa_skull, palette.red)
end

return {
  for_window = function(window, pane, extra) return make() end,
  for_tab = function(tab_info, extra) return make() end
}
