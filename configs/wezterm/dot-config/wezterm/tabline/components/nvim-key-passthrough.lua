local wezterm = require('wezterm')
local component = require('tabline.component')
local nvim_support = require('nvim-support')
local palette = require('tabline.palette')

local keys_passed_to_nvim_component = component.new('on', wezterm.nerdfonts.custom_neovim, palette.green)
local keys_passed_to_wezterm_component = component.new('off', wezterm.nerdfonts.custom_neovim, palette.surface)

local toto = component.new('helllo')

local function make(pane_user_vars)
  if nvim_support.do_pass_keys_to_nvim(pane_user_vars) then
    return keys_passed_to_nvim_component
  end
  return keys_passed_to_wezterm_component
end

return {
  for_window = function(gui_window, pane)
    return make(pane:get_user_vars())
  end,
  for_tab = function(tab_info)
    local active_pane_info = tab_info.active_pane
    return make(active_pane_info.user_vars)
  end
}
