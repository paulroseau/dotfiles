local wezterm = require('wezterm')
local Component = require('my-tabline.component')
local colors = require('my-tabline.colors').colors

return {
  window = {

  },
  tab = {

  },
  invalid = Component:new('N/A', wezterm.nerdfonts.fa_skull, colors.red())
}
