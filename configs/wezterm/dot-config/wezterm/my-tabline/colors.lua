local wezterm = require('wezterm')
local events = require('utils.events')

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

local current_mode_color = palette.ansi[mode_color.normal_mode]

local function background()
  return palette.tab_bar and palette.tab_bar.background or palette.background
end

local function surface()
  return palette.cursor_bg or palette.bright[ansi_codes.grey] or palette.ansi[ansi_codes.grey]
end

function M.update_current_mode_color(window, _)
  local key_table = window:active_key_table()

  if mode_color[key_table] then
    current_mode_color = palette.ansi[mode_color[key_table]]
  else
    current_mode_color = palette.ansi[mode_color.normal_mode]
  end
end

function M.get_section_colors(section_index)
  local surface = surface()
  local background = background()

  local section_colors = {
    { foreground = background,         background = current_mode_color },
    { foreground = current_mode_color, background = surface },
    { foreground = palette.foreground, background = background },
  }

  return section_colors[math.fmod(section_index - 1, 3) + 1]
end

-- NB: we can't depend on is_hover here because this information is not in
-- tab_info, hence we can't know if the tab on the left/right is hovered to
-- adjust the separator background colors
function M.get_tab_background_color(is_active)
  if is_active then
    return surface()
  end
  return background()
end

function M.get_tab_foreground_color(is_active, is_hover, mode_color)
  if is_active then
    return mode_color
  elseif is_hover then
    return palette.ansi[ansi_codes.magenta]
  end
  return palette.foreground
end

function M.get_tab_colors(is_active, is_hover)
  local surface = surface()
  local foreground_color = M.get_tab_foreground_color(is_active, is_hover, current_mode_color)
  local background_color = M.get_tab_background_color(is_active)

  return { foreground = foreground_color, background = background_color }
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
