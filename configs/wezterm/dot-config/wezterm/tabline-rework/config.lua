local wezterm = require('wezterm')
local util = require('tabline-rework.util')

local M = {}

local function get_colors(theme)
  local colors = type(theme) == 'string' and wezterm.color.get_builtin_schemes()[theme] or theme
  local surface = colors.cursor and colors.cursor.bg or colors.ansi[1]
  local background = colors.tab_bar and colors.tab_bar.background or colors.background

  return {
    normal_mode = {
      a = { fg = background, bg = colors.ansi[5] },
      b = { fg = colors.ansi[5], bg = surface },
      c = { fg = colors.foreground, bg = background },
    },
    copy_mode = {
      a = { fg = background, bg = colors.ansi[4] },
      b = { fg = colors.ansi[4], bg = surface },
      c = { fg = colors.foreground, bg = background },
    },
    search_mode = {
      a = { fg = background, bg = colors.ansi[3] },
      b = { fg = colors.ansi[3], bg = surface },
      c = { fg = colors.foreground, bg = background },
    },
    tab = {
      active = { fg = colors.ansi[5], bg = surface },
      inactive = { fg = colors.foreground, bg = background },
      inactive_hover = { fg = colors.ansi[6], bg = surface },
    },
    colors = colors,
  }
end

function M.set(opts)
  M.theme = util.deep_extend(get_colors(opts.theme.color_scheme), opts.theme.overrides)
  M.components = opts.components
  M.tabs = opts.tabs
  M.sections = opts.sections
end

return M
