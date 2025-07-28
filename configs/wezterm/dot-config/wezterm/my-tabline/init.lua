local wezterm = require('wezterm')
local utils = require('utils')
local components = require('components')

local M = {}

local function section(window, default_options, colors, component_config, separator)
  local rendered_components = {}
  local is_first = true

  for component_name, component_options in pairs(component_config) do
    local options = utils.deep_extend(component_options, default_options)
    local component = components.window[component_name] and components[component_name](window) or
        components.invalid
    local get_component_fn = components[component_name]
    if get_component_fn then
      component = get_component_fn(window)
    end
    table.insert(rendered_components, component:render(options, colors))
  end
  return utils.concatenate(rendered_components, separator)
end

local function status(default_options, status_config, is_left)
end

function M.setup(wezterm_config)
  local config = require('my-tabline.config')
  config.set_colors(wezterm_config.color_scheme)

  wezterm.on('update-status', function(window, _)
    local left_status = status(config.default_options, config.left_status, true)
    local right_status = status(config.default_options, config.right_status, false)
    window:set_left_status(wezterm.format(left_status))
    window:set_right_status(wezterm.format(right_status))
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    -- return require('tabline.tabs').set_title(tab, hover)
  end)
end

return M
