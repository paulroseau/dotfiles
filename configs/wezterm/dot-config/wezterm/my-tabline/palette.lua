local wezterm = require('wezterm')
local events = require('utils.events')
local utils = require('my-tabline.utils')

local M = {}

local default_color_scheme = 'Tokyo Night Storm'
local current_palette = wezterm.color.get_builtin_schemes()[default_color_scheme]

local ansi_codes = {
  black = 1,
  red = 2,
  green = 3,
  yellow = 4,
  blue = 5,
  magenta = 6,
  cyan = 7,
  grey = 8,
}

local mode_color = {
  normal_mode = ansi_codes.blue,
  copy_mode = ansi_codes.yellow,
  search_mode = ansi_codes.red,
}

local current_mode_color = current_palette.ansi[mode_color.normal_mode]

function tab_bar_middle_background()
  return current_palette.tab_bar and current_palette.tab_bar.background or current_palette.background
end

function surface()
  return current_palette.cursor_bg or
      (current_palette.brights and current_palette.brights[ansi_codes.grey]) or
      (current_palette.ansi and current_palette.ansi[ansi_codes.grey])
end

function M.update_current_mode_color(window)
  local key_table = window:active_key_table()

  if mode_color[key_table] then
    current_mode_color = current_palette.ansi[mode_color[key_table]]
  else
    current_mode_color = current_palette.ansi[mode_color.normal_mode]
  end
end

local function set(color_scheme, overrides)
  current_palette = utils.deep_extend(
    wezterm.color.get_builtin_schemes()[color_scheme],
    overrides or {}
  )
end

local grey_blue = '#3b4261'

local common_palette_overrides = {
  ['Tokyo Night'] = {
    cursor_bg = grey_blue
  },
  ['Tokyo Night Moon'] = {
    cursor_bg = grey_blue
  },
  ['Tokyo Night Storm'] = {
    cursor_bg = grey_blue
  },
  ['Solarized (dark) (terminal.sexy)'] = {
    surface = '#586e75',                   -- TODO
    tab_bar_middle_background = '#ff8822', -- TODO
  },
  ['Solarized (light) (terminal.sexy)'] = {
    surface = '#586e75',                   -- TODO
    tab_bar_middle_background = '#ff8822', -- TODO
  },
}

function M.set(color_scheme)
  current_palette = utils.deep_extend(
    wezterm.color.get_builtin_schemes()[color_scheme],
    common_palette_overrides[color_scheme] or {}
  )
end

return setmetatable(M, {
  __index = function(table, key)
    if key == 'current_mode' then
      return current_mode_color
    elseif current_palette[key] then
      return current_palette[key]
    elseif key == 'surface' then
      return surface()
    elseif key == 'tab_bar_middle_background' then
      return tab_bar_middle_background()
    elseif ansi_codes[key] then
      return current_palette.ansi[ansi_codes[key]]
    end
  end,
  __newindex = function(table, key, value)
    error('my-tabline.colors is read-only, use set_palette method to update', 2)
  end
})
