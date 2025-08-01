local wezterm = require('wezterm')
local component = require('my-tabline.component')

local default_icon = wezterm.nerdfonts.md_monitor

local domain_type_to_icon = {
  ['local'] = wezterm.nerdfonts.md_monitor,
  ssh = wezterm.nerdfonts.md_ssh,
  sshmux = wezterm.nerdfonts.md_ssh,
  wsl = wezterm.nerdfonts.md_microsoft_windows,
  docker = wezterm.nerdfonts.md_docker,
  unix = wezterm.nerdfonts.cod_terminal_linux,
}

local function make(pane)
  local domain_name = pane:get_domain_name()
  local domain_type, new_domain_name = domain_name:match('^([^:]+):?(.*)')
  domain_type = domain_type:lower()
  local text = new_domain_name ~= '' and new_domain_name or domain_name
  local icon = domain_type_to_icon[domain_type] or default_icon

  return component.new(text, icon)
end

return {
  window = function(window) return make(window:active_pane()) end,
  tab = function(tab_info) return make(tab_info:active_pane()) end
}
