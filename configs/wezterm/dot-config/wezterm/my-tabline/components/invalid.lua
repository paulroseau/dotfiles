local wezterm = require('wezterm')
local component = require('my-tabline.component')
local colors = require('my-tabline.colors')

local function make(_)
  return component.new('N/A', wezterm.nerdfonts.fa_skull, colors.red)
end

return {
  for_window = function(_) return make() end,
  for_tab = function(_) return make() end,
}
