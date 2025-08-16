local wezterm = require('wezterm')
local component = require('my-tabline.component')
local palette = require('my-tabline.palette')

local function battery_icon(battery_level, is_charging)
  local suffix = nil
  if battery_level < 10 then
    suffix = '_outline'
  else
    suffix = '_' .. string.format('%d', battery_level // 10) .. '0'
  end

  if is_charging then
    return wezterm.nerdfonts['md_battery_charging' .. suffix]
  end
  return wezterm.nerdfonts['md_battery' .. (battery_level < 100 and suffix or '')]
end

local function make()
  -- wezterm.battery_info() returns an array in case we have several batteries
  local battery_info = wezterm.battery_info()[1]
  local is_charging = battery_info.state == 'Charging'
  local battery_level = battery_info.state_of_charge * 100
  local text = string.format('%.0f%%', battery_level)
  local icon = battery_icon(battery_level, is_charging)
  if battery_level < 20 and not is_charging then
    return component.new(text, icon, palette.red)
  end
  return component.new(text, icon)
end

return {
  for_window = function(window, pane) return make() end,
  for_tab = function(tab_info) return make() end
}
