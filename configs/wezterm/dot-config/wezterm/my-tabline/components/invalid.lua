local wezterm = require('wezterm')
local component = require('my-tabline.component')
local colors = require('my-tabline.colors')

local function make(_)
  return component.new('N/A', wezterm.nerdfonts.fa_skull, colors.red)
end

return {
  window = make,
  tab = make
}
