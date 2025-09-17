local wezterm = require('wezterm')

local components = require('tabline.components')
local config = require('tabline.config')
local palette = require('tabline.palette')
local render = require('tabline.render')
local utils = require('utils')

local M = {}

local function section(
    available_components,
    default_options,
    colors,
    components_configs,
    internal_separator
)
  local rendered_components = {}

  for _, component_config in ipairs(components_configs) do
    local component = available_components(component_config.name)
    if type(component) == 'function' then
      component = component(component_config.args or {})
    end

    local options = utils.deep_extend(default_options, component_config.options or {})
    table.insert(rendered_components, render.component(component, options, colors))
  end

  return utils.flatten(rendered_components, render.make_text(internal_separator))
end

local function status(window, pane, default_options, status_config, is_left, edge_color)
  local rendered_sections = {}
  local previous_section_background_color = nil
  local separator = nil

  local section_configs = is_left and status_config.sections or utils.reverse(status_config.sections)
  for section_index, section_config in ipairs(section_configs) do
    local section_colors = {
      foreground = section_config.colors.foreground(),
      background = section_config.colors.background(),
    }

    if previous_section_background_color then
      separator = render.separator(
        status_config.separators.primary,
        previous_section_background_color,
        section_colors.background
      )
      table.insert(rendered_sections, separator)
    end
    previous_section_background_color = section_colors.background

    local section = section(
      components.for_window(window, pane),
      default_options,
      section_colors,
      section_config.components,
      status_config.separators.secondary
    )
    table.insert(rendered_sections, section)
  end

  separator = render.separator(status_config.separators.primary, previous_section_background_color, edge_color)
  table.insert(rendered_sections, separator)

  if not is_left then
    rendered_sections = utils.reverse(rendered_sections)
  end

  return utils.flatten(rendered_sections)
end

local function tab(tab_info, tabs_info, is_hover, default_options, tab_config)
  local tab_index = tab_info.tab_index + 1

  local tab_colors = {
    foreground = tab_config.colors.foreground(tab_info.is_active, is_hover, tab_index),
    background = tab_config.colors.background(tab_info.is_active, tab_index),
  }

  default_options = utils.deep_extend(
    default_options,
    tab_config.options(tab_info.is_active, is_hover, tab_index)
  )

  local title = section(
    components.for_tab(tab_info),
    default_options,
    tab_colors,
    tab_config.components,
    ''
  )

  local next_background_color = palette.tab_bar_middle_background
  if tab_index < #tabs_info then
    local next_tab_info = tabs_info[tab_index + 1]
    next_background_color = tab_config.colors.background(next_tab_info.is_active, tab_index + 1)
  end
  local separator = render.separator(tab_config.separator, tab_colors.background, next_background_color)

  return title, separator
end

function reload(config_overrides)
  if config_overrides.color_scheme then
    palette.set(config_overrides.color_scheme)
  end
  if config_overrides.tab_and_split_indices_are_zero_based then
    config.set_extra('zero_based_tabs_index', config_overrides.tab_and_split_indices_are_zero_based)
  end
end

function M.setup(wezterm_config)
  config.set_extra('zero_based_tabs_index', wezterm_config.tab_and_split_indices_are_zero_based)
  palette.set(wezterm_config.color_scheme)

  wezterm.on('update-status', function(window, pane)
    palette.update_current_mode_color(window)

    local first_tab_index = 1
    local first_tab = window:mux_window():tabs_with_info()[first_tab_index]
    local first_tab_background_color = config.tabs.colors.background(first_tab.is_active, first_tab_index)
    local left_status = status(window, pane, config.default_options, config.left_status, true, first_tab_background_color)
    window:set_left_status(wezterm.format(left_status))

    local right_status = status(window, pane, config.default_options, config.right_status, false,
      palette.tab_bar_middle_background)
    window:set_right_status(wezterm.format(right_status))
  end)

  wezterm.on('format-tab-title', function(tab_info, tabs_info, _, _, hover, _)
    local title, separator = tab(tab_info, tabs_info, hover, config.default_options, config.tabs)
    local mux_tab = wezterm.mux.get_tab(tab_info.tab_id)
    -- mux_tab:set_title(wezterm.format(title)) -- to allow to fuzzy select the title (otherwise titles remain empty)
    return utils.flatten({ title, separator })
  end)

  wezterm.on('window-config-reloaded', function(window, pane)
    local overrides = window:get_config_overrides()
    if overrides then reload(overrides) end
  end)
end

return M
