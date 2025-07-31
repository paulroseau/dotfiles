local wezterm = require('wezterm')

local M = {}

local default_color_scheme = 'Tokyo Night Storm'
local palette = wezterm.color.get_builtin_schemes()[default_color_scheme]

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

local function get_mode_color(window)
  local key_table = window:active_key_table()

  if mode_color[key_table] then
    return palette.ansi[mode_color[key_table]]
  end

  return palette.ansi[mode_color.normal_mode]
end

local function background()
  return palette.tab_bar and palette.tab_bar.background or palette.background
end

local function surface()
  return palette.cursor_bg or palette.bright[ansi_codes.grey] or palette.ansi[ansi_codes.grey]
end

function M.get_section_colors(window, section_index)
  local surface = surface()
  local background = background()
  local mode_color = get_mode_color(window)

  local section_colors = {
    { foreground = background,         background = mode_color },
    { foreground = mode_color,         background = surface },
    { foreground = palette.foreground, background = background },
  }

  return section_colors[math.fmod(section_index - 1, 3) + 1]
end

function M.get_tab_colors(is_active, is_hover, mode)
  local surface = surface()
  local background = background()

  if is_active then
    return { foreground = palette.ansi[mode_color[mode]], background = surface }
  elseif is_hover then
    return { foreground = palette.ansi[ansi_codes.magenta], background = surface }
  end

  return { foreground = palette.foreground, background = background }
end

function M.set_palette(color_scheme)
  if type(color_scheme) == 'string' then
    palette = wezterm.color.get_builtin_schemes()[color_scheme]
  else
    palette = color_scheme
  end
end

return setmetatable(M, {
  __index = function(table, key)
    if ansi_codes[key] then
      return palette.ansi[ansi_codes[key]]
    elseif key == 'background' then
      return background()
    elseif key == 'surface' then
      return surface()
    end
  end,
  __newindex = function(table, key, value)
    error('my-tabline.colors is read-only, use set_palette method to update', 2)
  end
})
