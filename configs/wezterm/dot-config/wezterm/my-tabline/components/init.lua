local wezterm = require('wezterm')
local component = require('my-tabline.component')
local colors = require('my-tabline.colors')

return {
  window = {

  },
  tab = {

  },
  invalid = component.new('N/A', wezterm.nerdfonts.fa_skull, colors.red)
}
