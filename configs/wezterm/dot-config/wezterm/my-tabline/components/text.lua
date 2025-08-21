local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(text, icon)
  return component.new(text, icon)
end

return {
  for_window = function(args) return make(args.text, args.icon) end,
  for_tab = function(args) return make(args.text, args.icon) end
}
