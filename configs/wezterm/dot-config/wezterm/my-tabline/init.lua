local wezterm = require('wezterm')
local utils = require('my-tabline.utils')
local components = require('my-tabline.components')
local colors = require('my-tabline.colors')
local render = require('my-tabline.render')

local M = {}

local function section(window, default_options, colors, component_config, separator)
  local rendered_components = {}

  for component_name, component_options in pairs(component_config) do
    local options = utils.deep_extend(default_options, component_options)
    local component = components.window[component_name] and components.window[component_name](window) or
        components.invalid
    table.insert(rendered_components, render.component(component, options, colors))
  end
  return utils.flatten(rendered_components, separator)
end

local function status(window, default_options, status_config, is_left)
  local rendered_sections = {}
  local previous_section_background_color = nil
  local separator = nil

  for index, section_config in ipairs(status_config.sections) do
    local section_index = is_left and index or #status_config.sections - index + 1
    local section_colors = colors.get_section_colors(window, section_index)

    if previous_section_background_color then
      separator = render.separator(status_config.separators.primary, previous_section_background_color,
        section_colors.background)
      table.insert(rendered_sections, { separator })
      previous_section_background_color = section_colors.background
    end

    local section = section(window, default_options, section_colors, section_config.components,
      status_config.separators.secondary)
    table.insert(rendered_sections, { section })
  end

  separator = render.separator(status_config.separators.primary, previous_section_background_color, colors.background)
  table.insert(rendered_sections, { separator })

  if not is_left then
    rendered_sections = utils.reverse(rendered_sections)
  end

  return utils.flatten(rendered_sections)
end

function M.setup(wezterm_config)
  local config = require('my-tabline.config')
  local colors = require('my-tabline.colors')
  colors.set_palette(wezterm_config.color_scheme)

  wezterm.on('update-status', function(window, _)
    local left_status = status(window, config.default_options, config.left_status, true)
    print(left_status)
    local right_status = status(window, config.default_options, config.right_status, false)
    window:set_left_status(wezterm.format(left_status))
    window:set_right_status(wezterm.format(right_status))
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    -- return require('tabline.tabs').set_title(tab, hover)
  end)
end

return M
