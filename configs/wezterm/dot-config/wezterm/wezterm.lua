local wezterm = require('wezterm')

local act = wezterm.action
local config = wezterm.config_builder()

local nvim_support = require('utils.nvim-support')
local extra_actions = require('utils.extra-action')
local fonts = require('utils.fonts')

-- we install fonts with nix and we link them to ~/.dotfiles/fonts
-- if nix is not available let's not bother to install fonts manually, let's just use the default
local nix_installed_fonts_dir = wezterm.home_dir .. '/.dotfiles/fonts'
if #wezterm.glob(nix_installed_fonts_dir) > 0 then
  config.font_dirs = { nix_installed_fonts_dir }
  fonts.set_font('hurmit', config)
end
config.color_scheme = 'Tokyo Night Storm'

local nix_installed_shell = wezterm.home_dir .. "/.nix-profile/bin/zsh"
if #wezterm.glob(nix_installed_shell) > 0 then
  config.default_prog = { nix_installed_shell, '--login' }
end

config.window_decorations = "RESIZE"
config.initial_rows = 45
config.initial_cols = 150
config.window_padding = {
  left = '0cell',
  right = '0cell',
  top = '0.1cell',
  bottom = '0cell',
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
  { key = 'c',  mods = 'CTRL|SHIFT',   action = extra_actions.select_color_scheme },

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
  { key = 's',  mods = 'LEADER',       action = extra_actions.select_workspace },
  { key = 's',  mods = 'LEADER|CTRL',  action = extra_actions.select_workspace },

  -- tabs
  { key = 'c',  mods = 'LEADER',       action = extra_actions.spawn_tab },
  { key = ',',  mods = 'LEADER',       action = extra_actions.rename_tab },
  { key = 'w',  mods = 'LEADER',       action = extra_actions.close_current_tab },
  { key = 'h',  mods = 'CTRL',         action = extra_actions.activate_tab_relative(-1) },
  { key = 'l',  mods = 'CTRL',         action = extra_actions.activate_tab_relative(1) },
  { key = 'h',  mods = 'CTRL|META',    action = act.MoveTabRelative(-1) },
  { key = 'l',  mods = 'CTRL|META',    action = act.MoveTabRelative(1) },

  -- panes
  { key = 'b',  mods = 'LEADER',       action = extra_actions.move_pane_to_new_tab },
  { key = 'b',  mods = 'LEADER|SHIFT', action = extra_actions.send_pane_to_new_tab },
  { key = 'x',  mods = 'LEADER',       action = extra_actions.close_current_pane },
  { key = 'z',  mods = 'META',         action = act.TogglePaneZoomState },
  { key = '\\', mods = 'META',         action = extra_actions.toggle_ignore_nvim_running_flag },
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

require('tabline').setup({
  theme = {
    color_scheme = 'Tokyo Night Storm',
    overrides = {},
  },
  components = {
    icons_enabled = true,
    icons_only = false,
    padding = 1,
    separators = { left = '╲', right = '╱', },
  },
  tabs = {
    enabled = true,
    tab_active = {
      { 'process', padding = { left = 1, right = 0 }, icons_only = true },
      { 'cwd',     padding = { left = 0, right = 1 } },
      { 'zoomed',  padding = 0 },
    },
    tab_inactive = {
      { 'process', padding = { left = 1, right = 0 }, icons_only = true },
      { 'cwd',     padding = { left = 0, right = 1 } },
      { 'zoomed',  padding = 0 },
    },
    -- separators = { left = '', right = '', }
    -- separators = { left = '', right = '', }
    separators = { left = '', right = '', },
  },
  sections = {
    tabline_a = { 'domain', },
    tabline_b = { 'workspace', },
    tabline_c = { '' },
    tabline_x = { '' },
    tabline_y = { 'ram', 'cpu' },
    tabline_z = { 'battery', 'datetime' },
    separators = { left = '', right = '', },
    -- separators = { left = '', right = '', },
  },
})

return config
