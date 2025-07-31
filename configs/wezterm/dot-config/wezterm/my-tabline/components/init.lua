local wezterm = require('wezterm')
local component = require('my-tabline.component')
local colors = require('my-tabline.colors')

return {
  window = {
    battery = require('my-tabline.components.window.battery'),
    datetime = require('my-tabline.components.window.datetime'),
  },
  tab = {

  },
  invalid = component.new('N/A', wezterm.nerdfonts.fa_skull, colors.red)
}
