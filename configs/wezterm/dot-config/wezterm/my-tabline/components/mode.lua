local wezterm = require('wezterm')
local component = require('my-tabline.component')

local key_table_to_mode = {
  normal_mode = component.new('NORMAL', wezterm.nerdfonts.cod_terminal),
  copy_mode = component.new('COPY', wezterm.nerdfonts.cod_copy),
  search_mode = component.new('SEARCH', wezterm.nerdfonts.cod_search)
}

local function make(window)
  local key_table = window:active_key_table()
  return key_table_to_mode[key_table] or key_table_to_mode.normal_mode
end

return {
  window = make,
  tab = function(tab_info)
    local window = wezterm.mux.get_window(tab_info.window_id)
    return make(window)
  end
}
