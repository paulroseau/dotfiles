local wezterm = require('wezterm')
local component = require('my-tabline.component')

local function F(_)
  local workspace = wezterm.mux.get_active_workspace()
  local text = string.match(workspace, '[^/\\]+$')
  local icon = wezterm.nerdfonts.cod_terminal_tmux
  return component.new(text, icon)
end

return F
