local wezterm = require('wezterm')
local component = require('my-tabline.component')

local key_table_to_mode = {
  normal_mode = component.new('NORMAL', wezterm.nerdfonts.cod_terminal),
  copy_mode = component.new('COPY', wezterm.nerdfonts.cod_copy),
  search_mode = component.new('SEARCH', wezterm.nerdfonts.cod_search)
}

return {
  for_window = function(args)
    local key_table = args.window:active_key_table()
    return key_table_to_mode[key_table] or key_table_to_mode.normal_mode
  end,
  -- There is no way to get the active_key_table from tab_info since we can't
  -- perform any asynchronous calls in the callback to format-tab-title and
  -- wezterm.gui.gui_window_for_mux_window(tab_info.window_id) is
  -- asynchronous
  -- Hence for_tab is not supported
  for_tab = nil
}
