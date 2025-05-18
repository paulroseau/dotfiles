local wezterm = require('wezterm')

local nvim_support = require("utils.nvim-support")
local extra_action = require("utils.extra-action")

local act = wezterm.action
local config = wezterm.config_builder()

-- we install fonts with nix and we link them there, if nix is not available
-- let's not bother to install fonts manually and just use the default
if #wezterm.glob(wezterm.home_dir .. "/.dotfiles/fonts") > 0 then
  config.font = wezterm.font("Hurmit Nerd Font")
end
config.color_scheme = 'Tokyo Night'

local nix_installed_shell = wezterm.home_dir .. "/.nix-profile/bin/zsh"
if #wezterm.glob(nix_installed_shell) > 0 then
  config.default_prog = { nix_installed_shell, '--login' }
end

config.window_decorations = "RESIZE"
config.window_padding = {
  left = '0cell',
  right = '0cell',
  top = '0.1cell',
  bottom = '0cell',
}

config.tab_and_split_indices_are_zero_based = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

config.unzoom_on_switch_pane = false

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- terminal
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
  { key = 'q', mods = 'LEADER', action = act.QuitApplication },
  { key = '=', mods = 'CTRL', action = act.ResetFontSize },
  { key = 'f', mods = 'CTRL|SHIFT', action = act.ToggleFullScreen, },

  -- sending keys
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'l', mods = 'LEADER', action = act.SendKey { key = 'l', mods = 'CTRL' } },

  -- copy/search mode
  { key = '[', mods = 'LEADER', action = extra_action.copy_mode_activate_no_selection },
  { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },

  -- domains
  { key = 'd', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'DOMAINS' } },  -- can't trigger pane-focused-in :-/

  -- workspaces
  { key = 'n', mods = 'LEADER|SHIFT', action = extra_action.spawn_workspace },
  { key = 'r', mods = 'LEADER|SHIFT', action = extra_action.rename_workspace },
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } }, -- can't trigger pane-focused-in :-/
  { key = 's', mods = 'LEADER|CTRL', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } }, -- can't trigger pane-focused-in :-/

  -- tabs
  { key = 'c', mods = 'LEADER', action = extra_action.spawn_tab },
  { key = ',', mods = 'LEADER', action = extra_action.rename_tab },
  { key = 'w', mods = 'CTRL|SHIFT', action = extra_action.close_current_tab },
  { key = 'h', mods = 'CTRL', action = extra_action.activate_tab_relative(-1) },
  { key = 'l', mods = 'CTRL', action = extra_action.activate_tab_relative(1) },
  { key = 'h', mods = 'CTRL|META', action = act.MoveTabRelative(-1) },
  { key = 'l', mods = 'CTRL|META', action = act.MoveTabRelative(1) },

  -- panes
  { key = 'b', mods = 'LEADER', action = extra_action.move_pane_to_new_tab },
  { key = 'b', mods = 'LEADER|SHIFT', action = extra_action.send_pane_to_new_tab },
  { key = 'x', mods = 'LEADER', action = extra_action.close_current_pane },
  { key = 'z', mods = 'META', action = act.TogglePaneZoomState },
  { key = '\\', mods = 'META', action = extra_action.toggle_ignore_nvim_running_flag },
  nvim_support.assign_key { key = 's', mods = 'META', action = extra_action.split_pane { direction = 'Up' } },
  nvim_support.assign_key { key = 'v', mods = 'META', action = extra_action.split_pane { direction = 'Right' } },
  nvim_support.assign_key { key = 'n', mods = 'META', action = extra_action.split_pane { direction = 'Up' } },
  nvim_support.assign_key { key = 'm', mods = 'META', action = extra_action.split_pane { direction = 'Right' } },
  nvim_support.assign_key { key = 'h', mods = 'META', action = extra_action.activate_pane_direction 'Left' },
  nvim_support.assign_key { key = 'j', mods = 'META', action = extra_action.activate_pane_direction 'Down' },
  nvim_support.assign_key { key = 'k', mods = 'META', action = extra_action.activate_pane_direction 'Up' },
  nvim_support.assign_key { key = 'l', mods = 'META', action = extra_action.activate_pane_direction 'Right' },
  nvim_support.assign_key { key = 'r', mods = 'META', action = act.RotatePanes 'Clockwise' },
  nvim_support.assign_key { key = 'R', mods = 'META', action = act.RotatePanes 'CounterClockwise' },
  nvim_support.assign_key { key = '<', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Left', 2 } },
  nvim_support.assign_key { key = '-', mods = 'META', action = act.AdjustPaneSize { 'Down', 2 } },
  nvim_support.assign_key { key = '+', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Up', 2 } },
  nvim_support.assign_key { key = '>', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Right', 2 } },
}

local copy_mode = nil
local search_mode = nil

if wezterm.gui then
  copy_mode = wezterm.gui.default_key_tables().copy_mode
  search_mode = wezterm.gui.default_key_tables().search_mode

  local copy_mode_keys = {
    { key = 'y', mods = 'NONE', action = extra_action.copy_mode_yank_and_exit },
    { key = 'n', mods = 'NONE', action = extra_action.copy_mode_next_match },
    { key = 'n', mods = 'SHIFT', action = extra_action.copy_mode_prior_match },
    { key = 'Backspace', mods = 'NONE', action = act.CopyMode 'ClearPattern' },
    { key = '/', mods = 'NONE', action = extra_action.copy_mode_start_search },
  }

  for _, key in pairs(copy_mode_keys) do
    table.insert(copy_mode, key)
  end

  local search_mode_keys = {
    { key = 'c', mods = 'CTRL', action = extra_action.exit_copy_mode },
    { key = 'w', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
    { key = 'Enter', mods = 'NONE', action = extra_action.search_mode_validate },
  }

  for _, key in pairs(search_mode_keys) do
    table.insert(search_mode, key)
  end

  config.key_tables = {
    copy_mode = copy_mode,
    search_mode = search_mode
  }
end


-- Event handlers
nvim_support.set_on_pane_focused_in_handler()

wezterm.on('gui-startup', function(cmd)
  local _, pane, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  gui_window:perform_action(act.ToggleFullScreen, pane)
end)

-- wezterm.on('update-right-status', function(window, pane)
--   local right_status = "workspace: " .. window:active_workspace()
--   if nvim_support.get_ignore_nvim_running_flag() then
--     right_status = right_status .. " | nvim: ignore"
--   end
--   window:set_right_status(right_status)
-- end)

-- TODO
-- fonts make a separate config files with the font size associated to each font
-- you downlowd with nix, so that if you pick it you already have good settings
-- (Agave for instance is too small by default)
-- prettier tabs
-- prettier statusline
-- theme and size of window on wezterm
-- Create a domain dynamically ? needs to be added to wezterm -> no but prepare a config file to edit, test
--
-- Consider using the Input select for switching workspaces
-- actually launch nix's zsh if nix is there
--
-- Closing a workspace at once (not supported natively, lots of lua code cf. https://github.com/wezterm/wezterm/issues/3658, not worth it)
-- contribute to add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722
--
-- Wezterm Big issues at the moment:
--   search not intuitive, selection by default also when you come back, case sensitivity, there should be only 1 copy mode
--   missing choose-tree, more uniforms menus
--     import pane/tab from elsewhere (need choose-tree)
--   missing focus pane events
--   export pane/tab to new workspace (1 window/workspace)
--   move pane/tab to new workspace (1 window/workspace)
--   customizable keymaps in menu mode and search mode (editing part, emacs style would be good by default)
--   better vim movements in Copy Mode (e not respected, E, etc.)
--
-- Nvim issues:
--   resizing of the windows in not intuitive
--
-- Enhancement:
--    change layout like in nvim, right now you can just rotate panes
--    have a command line (vim style? C-a : and C-a /) with either emacs or vim mappings, but still customizable

return config
