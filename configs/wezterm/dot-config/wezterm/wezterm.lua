local wezterm = require('wezterm')

local act = wezterm.action
local config = wezterm.config_builder()

local nvim_support = require('nvim-support')
local extra_actions = require('extra-action')

local fonts = require('fonts')
-- Need to check the presence of the directory here because of https://github.com/wezterm/wezterm/issues/2401
local nix_installed_fonts_dir = wezterm.home_dir .. '/.nix-profile/share/fonts'
local nix_installed_fonts_dir_exists = #wezterm.glob(nix_installed_fonts_dir) > 0
fonts.setup(nix_installed_fonts_dir_exists)
fonts.set_font_if_available('hurmit', config)

config.color_scheme = 'Tokyo Night Storm'

local nix_installed_shell = wezterm.home_dir .. '/.nix-profile/bin/zsh'
if #wezterm.glob(nix_installed_shell) > 0 then
  config.default_prog = { nix_installed_shell, '--login' }
end

config.window_decorations = 'RESIZE'
config.initial_rows = 45
config.initial_cols = 150
config.window_padding = {
  left = '0px',
  right = '0px',
  top = '0px',
  bottom = '0px',
}

config.tab_and_split_indices_are_zero_based = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.unzoom_on_switch_pane = false

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- terminal
  { key = 'r',  mods = 'LEADER',       action = act.ReloadConfiguration },
  { key = 'q',  mods = 'LEADER',       action = act.QuitApplication },
  { key = 'f',  mods = 'CTRL|SHIFT',   action = act.ToggleFullScreen, },
  { key = 'c',  mods = 'CTRL|SHIFT',   action = require('selector').color_schemes },
  { key = 'f',  mods = 'META',         action = require('selector').fonts },

  -- fonts
  { key = '+',  mods = 'CTRL|SHIFT',   action = act.IncreaseFontSize },
  { key = '-',  mods = 'CTRL',         action = act.DecreaseFontSize },
  { key = '=',  mods = 'CTRL',         action = act.ResetFontSize },

  -- sending keys
  { key = 'a',  mods = 'LEADER|CTRL',  action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'l',  mods = 'LEADER',       action = act.SendKey { key = 'l', mods = 'CTRL' } },

  -- copy/search mode
  { key = '[',  mods = 'LEADER',       action = extra_actions.copy_mode_activate_no_selection },
  { key = '/',  mods = 'LEADER',       action = act.Search { CaseInSensitiveString = '' } },

  -- domains
  { key = 'd',  mods = 'LEADER',       action = act.ShowLauncherArgs { flags = 'DOMAINS' } }, -- can't trigger pane-focused-in :-/

  -- workspaces
  { key = 'n',  mods = 'LEADER|SHIFT', action = extra_actions.spawn_new_workspace },
  { key = 'r',  mods = 'LEADER|SHIFT', action = extra_actions.rename_workspace },
  { key = 's',  mods = 'LEADER',       action = require('selector').workspaces },
  { key = 's',  mods = 'LEADER|CTRL',  action = require('selector').workspaces },

  -- tabs
  { key = 'c',  mods = 'LEADER',       action = extra_actions.spawn_tab },
  { key = 'w',  mods = 'LEADER',       action = extra_actions.close_current_tab },
  { key = 'h',  mods = 'CTRL',         action = extra_actions.activate_tab_relative(-1) },
  { key = 'l',  mods = 'CTRL',         action = extra_actions.activate_tab_relative(1) },
  { key = 'h',  mods = 'CTRL|META',    action = act.MoveTabRelative(-1) },
  { key = 'l',  mods = 'CTRL|META',    action = act.MoveTabRelative(1) },
  { key = 't',  mods = 'LEADER',       action = require('selector').tabs },

  -- panes
  { key = 'b',  mods = 'LEADER',       action = extra_actions.move_pane_to_new_tab },
  { key = 'b',  mods = 'LEADER|SHIFT', action = extra_actions.send_pane_to_new_tab },
  { key = 'x',  mods = 'LEADER',       action = extra_actions.close_current_pane },
  { key = 'z',  mods = 'META',         action = act.TogglePaneZoomState },
  { key = '\\', mods = 'META',         action = nvim_support.toggle_ignore_nvim_running_flag },
  nvim_support.assign_key { key = 's', mods = 'META', action = extra_actions.split_pane { direction = 'Up' } },
  nvim_support.assign_key { key = 'v', mods = 'META', action = extra_actions.split_pane { direction = 'Right' } },
  nvim_support.assign_key { key = 'n', mods = 'META', action = extra_actions.split_pane { direction = 'Up' } },
  nvim_support.assign_key { key = 'm', mods = 'META', action = extra_actions.split_pane { direction = 'Right' } },
  nvim_support.assign_key { key = 'h', mods = 'META', action = extra_actions.activate_pane_direction 'Left' },
  nvim_support.assign_key { key = 'j', mods = 'META', action = extra_actions.activate_pane_direction 'Down' },
  nvim_support.assign_key { key = 'k', mods = 'META', action = extra_actions.activate_pane_direction 'Up' },
  nvim_support.assign_key { key = 'l', mods = 'META', action = extra_actions.activate_pane_direction 'Right' },
  nvim_support.assign_key { key = 'r', mods = 'META', action = act.RotatePanes 'Clockwise' },
  nvim_support.assign_key { key = 'R', mods = 'META', action = act.RotatePanes 'CounterClockwise' },
  nvim_support.assign_key { key = '<', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Left', 2 } },
  nvim_support.assign_key { key = '+', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Down', 2 } },
  nvim_support.assign_key { key = '-', mods = 'META', action = act.AdjustPaneSize { 'Up', 2 } },
  nvim_support.assign_key { key = '>', mods = 'META|SHIFT', action = act.AdjustPaneSize { 'Right', 2 } },
}

local copy_mode = nil
local search_mode = nil

if wezterm.gui then
  copy_mode = wezterm.gui.default_key_tables().copy_mode
  search_mode = wezterm.gui.default_key_tables().search_mode

  local copy_mode_keys = {
    { key = 'y',         mods = 'NONE',  action = extra_actions.copy_mode_yank_and_exit },
    { key = 'n',         mods = 'NONE',  action = extra_actions.copy_mode_next_match },
    { key = 'n',         mods = 'SHIFT', action = extra_actions.copy_mode_prior_match },
    { key = 'Backspace', mods = 'NONE',  action = act.CopyMode 'ClearPattern' },
    { key = '/',         mods = 'NONE',  action = extra_actions.copy_mode_start_search },
  }

  for _, key in pairs(copy_mode_keys) do
    table.insert(copy_mode, key)
  end

  local search_mode_keys = {
    { key = 'c',     mods = 'CTRL', action = extra_actions.exit_copy_mode },
    { key = 'w',     mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
    { key = 'Enter', mods = 'NONE', action = extra_actions.search_mode_validate },
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

-- local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
--
-- tabline.setup({
--   options = {
--     icons_enabled = true,
--     theme = 'Catppuccin Mocha',
--     tabs_enabled = true,
--     theme_overrides = {},
--     section_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--     component_separators = {
--       left = wezterm.nerdfonts.pl_left_soft_divider,
--       right = wezterm.nerdfonts.pl_right_soft_divider,
--     },
--     tab_separators = {
--       left = wezterm.nerdfonts.pl_left_hard_divider,
--       right = wezterm.nerdfonts.pl_right_hard_divider,
--     },
--   },
--   sections = {
--     tabline_a = { 'mode', },
--     tabline_b = { 'workspace' },
--     tabline_c = { ' ' },
--     tab_active = {
--       'index',
--       { 'parent', padding = 0 },
--       '/',
--       { 'cwd',    padding = { left = 0, right = 1 } },
--       { 'zoomed', padding = 0 },
--     },
--     tab_inactive = {
--       'index',
--       { 'process', padding = { left = 0, right = 1 } }
--     },
--     tabline_x = { 'ram', 'cpu' },
--     tabline_y = { 'datetime', 'battery' },
--     tabline_z = { 'datetime', 'battery', },
--   },
--   extensions = {},
-- })

-- local palette = {
--   black = "#1d202f",
--   red = "#f7768e",
--   green = "#9ece6a",
--   yellow = "#e0af68",
--   blue = "#7aa2f7",
--   magenta = "#bb9af7",
--   cyan = "#7dcfff",
--   grey = "#a9b1d6",
--   grey_blue = '#3b4261',
-- }
--
-- require('tabline').setup({
--   theme = {
--     color_scheme = 'Tokyo Night Storm',
--     overrides = {
--       normal_mode = {
--         b = { bg = palette.grey_blue },
--       },
--       copy_mode = {
--         b = { bg = palette.grey_blue },
--       },
--       search_mode = {
--         b = { bg = palette.grey_blue },
--       },
--       tab = {
--         active = { bg = palette.grey_blue },
--         inactive_hover = { bg = palette.grey_blue },
--       },
--     },
--   },
--   components = {
--     icons_enabled = true,
--     icons_only = false,
--     padding = 1,
--     separators = { left = '╲', right = '╱', },
--   },
--   tabs = {
--     enabled = true,
--     tab_active = {
--       { 'process', padding = { left = 1, right = 0 }, icons_only = true },
--       { 'cwd',     padding = { left = 0, right = 1 } },
--       { 'zoomed',  padding = 0 },
--     },
--     tab_inactive = {
--       { 'process', padding = { left = 1, right = 0 }, icons_only = true },
--       { 'cwd',     padding = { left = 0, right = 1 } },
--       { 'zoomed',  padding = 0 },
--       { 'output',  padding = 0 },
--     },
--     separators = { left = '', right = '', },
--   },
--   sections = {
--     tabline_a = { 'domain', },
--     tabline_b = { 'workspace', },
--     tabline_c = { 'datetime' },
--     tabline_x = { '' },
--     tabline_y = { 'ram', 'cpu' },
--     tabline_z = { { 'battery' }, { 'datetime' } },
--     separators = { left = '', right = '', },
--   },
-- })

require('my-tabline').setup(config)

return config
