local wezterm = require('wezterm')
local component = require('my-tabline.component')

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
  window = function(window, pane, extra) return make(pane:get_current_working_dir()) end,
  tab = function(tab_info, extra) return make(tab_info.active_pane.current_working_dir) end
}
