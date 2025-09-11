local wezterm = require('wezterm')
local component = require('my-tabline.component')
local utils = require('utils')

local icon = wezterm.nerdfonts.cod_server
local unknown_memory_component = component.new('? GB', icon)
local last_update_time = 0
local last_result = unknown_memory_component

local function ram_component(memory_used_in_gb)
  if not memory_used_in_gb then
    return unknown_memory_component
  end
  local text = string.format('%.1f GB', memory_used_in_gb)
  return component.new(text, icon)
end

local function ram_on_linux()
  local success, result = wezterm.run_child_process {
    'bash',
    '-c',
    'free -m | LC_NUMERIC=C awk \'NR==2{printf "%.2f", $3/1000 }\''
  }

  return ram_component(success and result)
end

local function ram_on_macos()
  local success, result = wezterm.run_child_process { 'vm_stat' }

  local memory_used_in_gb = nil

  if success then
    local anonymous_pages = result:match('Anonymous pages: +(%d+).')
    local pages_purgeable = result:match('Pages purgeable: +(%d+).')
    local app_memory = anonymous_pages and pages_purgeable and (anonymous_pages - pages_purgeable)
    local wired_memory = result:match('Pages wired down: +(%d+).')
    local compressed_memory = result:match('Pages occupied by compressor: +(%d+).')
    local number_of_pages_used = app_memory and wired_memory and compressed_memory and
        (app_memory + wired_memory + compressed_memory)
    local page_size = result:match('page size of (%d+) bytes')
    memory_used_in_gb = number_of_pages_used and page_size and
        number_of_pages_used * page_size / 1024 / 1024 / 1024
  end
  return ram_component(memory_used_in_gb)
end

local function ram_on_windows()
  local success, result = wezterm.run_child_process {
    'cmd.exe',
    '/C',
    'wmic OS get FreePhysicalMemory',
  }

  local memory_used_in_gb = success and result:match('%d+') / 1024 / 1024
  return ram_component(memory_used_in_gb)
end

local function make(args)
  local current_time = os.time()
  if current_time - last_update_time < args.throttle then
    return last_result
  end

  local component = unknown_memory_component
  if utils.is_linux then
    component = ram_on_linux()
  elseif utils.is_macos then
    component = ram_on_macos()
  elseif utils.is_windows then
    component = ram_on_windows()
  end

  last_update_time = current_time
  last_result = component
  return component
end

return {
  for_window = function(gui_window, pane) return make end,
  for_tab = nil -- we can't fork a process in the callback of format-tab-title which needs to be synchronous
}
