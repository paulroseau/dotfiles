local component = require('my-tabline.component')

local function make(current_working_dir_uri)
  local file_path = current_working_dir_uri and current_working_dir_uri.file_path or '-'
  local text = file_path:match('([^/]+)/?$')
  return component.new(text)
end

return {
  for_window = function(args)
    local current_working_dir_uri = args.pane:get_current_working_dir()
    return make(current_working_dir_uri)
  end,
  for_tab = function(args)
    local current_working_dir_uri = args.tab_info.active_pane.current_working_dir
    return make(current_working_dir_uri)
  end
}
