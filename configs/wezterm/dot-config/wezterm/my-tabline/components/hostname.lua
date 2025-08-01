local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make(pane)
  local cwd_uri = pane:get_current_working_dir()
  local hostname = ''

  if cwd_uri == nil then
    hostname = wezterm.hostname()
  elseif type(cwd_uri) == 'userdata' then
    hostname = cwd_uri.host or wezterm.hostname()
  end

  local dot = hostname:find('[.]')
  if dot then
    hostname = hostname:sub(1, dot - 1)
  end

  return component.new(hostname, nil)
end

return {
  window = function(window) return make(window:active_pane()) end,
  tab = function(tab_info) return make(tab_info:active_pane()) end
}
