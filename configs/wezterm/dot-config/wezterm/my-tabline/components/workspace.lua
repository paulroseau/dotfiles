local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function make()
  local workspace = wezterm.mux.get_active_workspace()
  local text = string.match(workspace, '[^/\\]+$')
  local icon = wezterm.nerdfonts.cod_terminal_tmux
  return component.new(text, icon)
end

return {
  for_window = function(_) return make() end,
  for_tab = function(_) return make() end,
}
