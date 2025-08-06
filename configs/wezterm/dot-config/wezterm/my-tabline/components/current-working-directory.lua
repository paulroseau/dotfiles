local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function format(current_working_dir_uri)
  local file_path = current_working_dir_uri.file_path
  return file_path:match('([^/]+)/?$')
end

return {
  window = function(window)
    local pane = window:active_pane()
    local current_working_dir_uri = pane:get_current_working_dir()
    local text = format(current_working_dir_uri)
    return component.new(text)
  end,
  update = function(tab_info)
    local current_working_dir_uri = tab_info.active_pane.current_working_dir
    local text = format(current_working_dir_uri)
    return component.new(text)
  end,
}
