local wezterm = require('wezterm')
local component = require('my-tabline.component')
local utils = require('utils')

local icon = wezterm.nerdfonts.oct_cpu
local unknown_cpu_component = component.new('? %', icon)
local last_update_time = 0
local last_result = unknown_cpu_component

local function cpu_component(cpu_load)
  if not cpu_load then
    return unknown_cpu_component
  end
  local text = string.format('%.2f%%', cpu_load)
  return component.new(text, icon)
end

local function cpu_on_linux()
  local success, result = wezterm.run_child_process {
    'bash',
    '-c',
    "LC_NUMERIC=C awk '/^cpu / {print ($2+$4)*100/($2+$4+$5)}' /proc/stat",
  }

  local cpu_load = success and result:gsub('^%s*(.-)%s*$', '%1')
  return cpu_component(cpu_load)
end

local function cpu_on_macos()
  local success, result = wezterm.run_child_process {
    'bash',
    '-c',
    'ps -A -o %cpu | LC_NUMERIC=C awk \'{s+=$1} END {print s ""}\'',
  }
  local num_used_cores = success and result:gsub('^%s*(.-)%s*$', '%1')

  success, result = wezterm.run_child_process {
    'sysctl',
    '-n',
    'hw.ncpu',
  }
  local num_cores = success and result
  local cpu_load = num_used_cores and num_cores and num_used_cores / num_cores

  return cpu_component(cpu_load)
end

local function cpu_on_windows()
  local success, result = wezterm.run_child_process {
    'cmd.exe',
    '/C',
    'wmic cpu get loadpercentage',
  }

  local cpu_load = result:match('%d+')
  return cpu_component(cpu_load)
end

local function make(args)
  local current_time = os.time()
  if current_time - last_update_time < args.throttle then
    return last_result
  end

  local component = unknown_cpu_component
  if utils.is_linux then
    component = cpu_on_linux()
  elseif utils.is_macos then
    component = cpu_on_macos()
  elseif utils.is_windows then
    component = cpu_on_windows()
  end

  last_update_time = current_time
  last_result = component
  return component
end

return {
  for_window = function(gui_window, pane) return make end,
  for_tab = nil -- we can't fork a process in the callback of format-tab-title which needs to be synchronous
}
