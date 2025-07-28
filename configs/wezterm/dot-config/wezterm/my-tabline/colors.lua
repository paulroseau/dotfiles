local colors = require('my-tabline.config').colors

local M = {}

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

-- TODO add set color palette here rather than in config

-- todo remove that
local black = 1
local red = 2
local green = 3
local yellow = 4
local blue = 5
local magenta = 6
local cyan = 7
local grey = 8

local mode_color = {
  normal_mode = blue,
  copy_mode = yellow,
  search_mode = red,
}

local function get_mode_color(window)
  local key_table = window:active_key_table()

  if mode_color[key_table] then
    return colors.ansi[mode_color[key_table]]
  end

  return colors.ansi[mode_color.normal_mode]
end

local function get_background_colors()
  local background = colors.tab_bar and colors.tab_bar.background or colors.background
  local surface = colors.cursor_bg or colors.bright[grey] or colors.ansi[grey]
  return surface, background
end

-- TODO change that
function M.black() return colors.ansi[black] end

function M.red() return colors.ansi[red] end

function M.green() return colors.ansi[green] end

function M.yellow() return colors.ansi[yellow] end

function M.blue() return colors.ansi[blue] end

function M.magenta() return colors.ansi[magenta] end

function M.cyan() return colors.ansi[cyan] end

function M.grey() return colors.ansi[grey] end

function M.get_section_colors(window, section_index)
  local surface, background = get_background_colors()
  local mode_color = get_mode_color(window)

  local section_colors = {
    { foreground = background,        background = mode_color },
    { foreground = mode_color,        background = surface },
    { foreground = colors.foreground, background = background },
  }

  return section_colors[math.fmod(section_index, 3) + 1]
end

function M.get_tab_colors(is_active, is_hover, mode)
  local surface, background = get_background_colors()

  if is_active then
    return { foreground = colors.ansi[mode_color[mode]], background = surface }
  elseif is_hover then
    return { foreground = colors.ansi[magenta], background = surface, italic = true }
  end

  return { foreground = colors.foreground, background = background }
end

return M
