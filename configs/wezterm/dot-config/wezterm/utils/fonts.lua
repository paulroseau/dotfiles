local wezterm = require('wezterm')

local M = {}

local available_fonts = {
  ['agave'] = {
    full_name = 'Agave Nerd Font',
    size = 15
  },
  ['hack'] = {
    full_name = 'Hack Nerd Font',
    size = 12.5
  },
  ['hurmit'] = {
    full_name = 'Hurmit Nerd Font',
    size = 12.5
  },
  ['terminess'] = {
    full_name = 'Terminess Nerd Font',
    size = 14
  },
}

M.set_font = function(_font, config)
  font = available_fonts[_font]
  if font then
    config.font = wezterm.font(font.full_name)
    config.font_size = font.size
  end
end

return M
