local wezterm = require('wezterm')
local component = require('tabline.component')

local function make(current_working_dir_uri)
  if current_working_dir_uri == nil then
    hostname = wezterm.hostname()
  elseif type(current_working_dir_uri) == 'userdata' then
    hostname = current_working_dir_uri.host or wezterm.hostname()
  end

  local dot = hostname:find('[.]')
  if dot then
    hostname = hostname:sub(1, dot - 1)
  end

  return component.new(hostname, nil)
end

return {
  for_window = function(gui_window, pane) return make(pane:get_current_working_dir()) end,
  for_tab = function(tab_info) return make(tab_info.active_pane.current_working_dir) end
}
