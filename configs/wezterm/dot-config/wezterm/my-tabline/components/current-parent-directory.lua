local component = require('my-tabline.component')

local function make(current_working_dir_uri)
  local file_path = current_working_dir_uri and current_working_dir_uri.file_path
  if file_path then
    -- Replace backslashes with forward slashes for consistency
    file_path = file_path:gsub('\\', '/')
    -- Remove any leading and trailing slashes
    file_path = file_path:match('^/*(.-)/*$')
    text = file_path:match('([^/]*)/[^/]*$')
    return component.new(text)
  end
  return component.new('-')
end

return {
  for_window = function(window, pane)
    local current_working_dir_uri = pane:get_current_working_dir()
    return make(current_working_dir_uri)
  end,
  for_tab = function(tab_info)
    local current_working_dir_uri = tab_info.active_pane.current_working_dir
    return make(current_working_dir_uri)
  end
}
