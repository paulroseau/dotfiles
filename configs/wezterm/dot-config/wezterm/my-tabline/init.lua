local wezterm = require('wezterm')
local utils = require('my-tabline.utils')
local components = require('my-tabline.components')
local colors = require('my-tabline.colors')
local render = require('my-tabline.render')

local M = {}

local function section(available_components, component_args, default_options, colors, components_configs, separator)
  local rendered_components = {}

  for _, component_config in ipairs(components_configs) do
    local options = utils.deep_extend(default_options, component_config.options)
    local make_component = available_components[component_config.name]
    local component = make_component(component_args)
    table.insert(rendered_components, render.component(component, options, colors))
  end
  return utils.flatten(rendered_components, render.make_text(separator))
end

local function status(window, pane, default_options, status_config, is_left)
  local rendered_sections = {}
  local previous_section_background_color = nil
  local separator = nil

  local section_configs = is_left and status_config.sections or utils.reverse(status_config.sections)
  for section_index, section_config in ipairs(section_configs) do
    local section_colors = utils.deep_extend(
      colors.get_section_colors(section_index),
      section_config.colors or {}
    )

    if previous_section_background_color then
      separator = render.separator(status_config.separators.primary, previous_section_background_color,
        section_colors.background)
      table.insert(rendered_sections, separator)
    end
    previous_section_background_color = section_colors.background

    local section = section(components.for_window, { window = window, pane = pane }, default_options, section_colors,
      section_config.components,
      status_config.separators.secondary)
    table.insert(rendered_sections, section)
  end

  separator = render.separator(status_config.separators.primary, previous_section_background_color, colors.background)
  table.insert(rendered_sections, separator)

  if not is_left then
    rendered_sections = utils.reverse(rendered_sections)
  end

  return utils.flatten(rendered_sections)
end

local function tab(tab_info, tabs_info, is_hover, default_options, tab_config)
  local tab_colors = colors.get_tab_colors(tab_info.is_active, is_hover)
  local rendered_components = section(components.for_window, { tab_info = tab_info }, default_options, tab_colors,
    tab_config.components, '')

  local tab_index = tab_info.tab_index + 1

  local left_separator_previous_background_color = nil
  if tab_index == 1 then
    left_separator_previous_background_color = colors.background
  else
    left_separator_previous_background_color = colors.get_tab_background_color(tabs_info[tab_index - 1].is_active)
  end
  local left_separator = render.separator(tab_config.separators.left, left_separator_previous_background_color,
    tab_colors.background)

  local right_separator_next_background_color = nil
  if tab_index == #tabs_info then
    right_separator_next_background_color = colors.background
  else
    right_separator_next_background_color = colors.get_tab_background_color(tabs_info[tab_index - 1].is_active)
  end
  local right_separator = render.separator(tab_config.separators.right, tab_colors.background,
    right_separator_next_background_color)

  table.insert(rendered_components, 1, left_separator)
  table.insert(rendered_components, right_separator)
  return rendered_components
end

function M.setup(wezterm_config)
  local config = require('my-tabline.config')
  local colors = require('my-tabline.colors')
  colors.set_palette(wezterm_config.color_scheme)

  wezterm.on('update-status', function(window, pane)
    local left_status = status(window, pane, config.default_options, config.left_status, true)
    local right_status = status(window, pane, config.default_options, config.right_status, false)
    window:set_left_status(wezterm.format(left_status))
    window:set_right_status(wezterm.format(right_status))
  end)

  wezterm.on('format-tab-title', function(tab_info, tabs_info, _, _, hover, _)
    return tab(tab_info, tabs_info, hover, config.default_options, config.tabs)
  end)
end

return M
