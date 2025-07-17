local config = require('tabline.config')
local util = require('tabline.util')

local M = {}

local left_tab_separator = { Text = config.tabs.separator_left }
local right_tab_separator = { Text = config.tabs.separator_right }
local active_attributes, inactive_attributes, active_separator_attributes, inactive_separator_attributes =
    {}, {}, {}, {}
local tab_active, tab_inactive = {}, {}

local function create_attributes(hover)
  local colors = config.theme.tab
  active_attributes = {
    { Foreground = { Color = colors.active.fg } },
    { Background = { Color = colors.active.bg } },
  }
  inactive_attributes = {
    { Foreground = { Color = hover and colors.inactive_hover.fg or colors.inactive.fg } },
    { Background = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
  }
  active_separator_attributes = {
    { Foreground = { Color = colors.active.bg } },
    { Background = { Color = colors.inactive.bg } },
  }
  inactive_separator_attributes = {
    { Foreground = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
    { Background = { Color = colors.inactive.bg } },
  }
end

local function create_tab_content(tab)
  local config = config.tabs
  tab_active = util.extract_components(config.tab_active, active_attributes, tab)
  tab_inactive = util.extract_components(config.tab_inactive, inactive_attributes, tab)
end

local function tabs(tab)
  local result = {}

  if #tab_active > 0 and tab.is_active then
    util.insert_elements(result, active_separator_attributes)
    table.insert(result, right_tab_separator)
    util.insert_elements(result, active_attributes)
    util.insert_elements(result, tab_active)
    util.insert_elements(result, active_separator_attributes)
    table.insert(result, left_tab_separator)
  elseif #tab_inactive > 0 then
    util.insert_elements(result, inactive_separator_attributes)
    table.insert(result, right_tab_separator)
    util.insert_elements(result, inactive_attributes)
    util.insert_elements(result, tab_inactive)
    util.insert_elements(result, inactive_separator_attributes)
    table.insert(result, left_tab_separator)
  end
  return result
end

M.set_title = function(tab, hover)
  if not config.tabs.enabled then
    return
  end
  create_attributes(hover)
  create_tab_content(tab)
  return tabs(tab)
end

return M
