local wezterm = require('wezterm')
local utils = require('utils')

local M = {}

local builtin_fonts = {
  ['jetbrains mono'] = {
    full_name = 'JetBrains Mono',
    size = 12,
  },
}

local nix_installed_fonts = {
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

local available_fonts = builtin_fonts

function M.setup(nix_installed_fonts_dir_exists)
  if nix_installed_fonts_dir_exists then
    available_fonts = utils.deep_extend(builtin_fonts, nix_installed_fonts)
  end
end

function M.get_available_fonts()
  return available_fonts
end

function M.set_font_if_available(selected_font, config_to_update)
  local font = available_fonts[selected_font]
  if font then
    config_to_update.font = wezterm.font(font.full_name)
    config_to_update.font_size = font.size
  end
end

return M
