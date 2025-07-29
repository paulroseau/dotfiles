local wezterm = require('wezterm')
local utils = require('utils')
local components = require('components')

local M = {}

local function section(window, default_options, colors, component_config, separator)
  local rendered_components = {}
  local is_first = true

  for component_name, component_options in pairs(component_config) do
    local options = utils.deep_extend(component_options, default_options)
    local component = components.window[component_name] and components.window[component_name](window) or
        components.invalid
    table.insert(rendered_components, component:render(options, colors))
  end
  return utils.concatenate(rendered_components, separator)
end

local function status(window, default_options, status_config, is_left)
  -- get colors sequence (if is left reverse) (colors should be of length #status_config.sections + 1 to include the color of the middle tab bar (background))
  -- for each component
  -- if is left insert nothing else insert separator with right background
end

function M.setup(wezterm_config)
  local config = require('my-tabline.config')
  local colors = require('my-tabline.colors')
  colors.set_palette(wezterm_config.color_scheme)

  wezterm.on('update-status', function(window, _)
    local left_status = status(window, config.default_options, config.left_status, true)
    local right_status = status(window, config.default_options, config.right_status, false)
    window:set_left_status(wezterm.format(left_status))
    window:set_right_status(wezterm.format(right_status))
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    -- return require('tabline.tabs').set_title(tab, hover)
  end)
end

return M
