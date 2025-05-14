local wezterm = require('wezterm')
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font("Hurmit Nerd Font")
config.window_decorations = "RESIZE"
config.tab_and_split_indices_are_zero_based = true
config.tab_bar_at_bottom = true

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- need to bundle those in a function, with multiple we end up with SelectionMode on
local activate_copy_mode_without_selection = wezterm.action_callback(function(window, pane, _)
    window:perform_action(act.ActivateCopyMode, pane)
    window:perform_action(act.CopyMode 'MoveToSelectionOtherEnd', pane)
    window:perform_action(act.CopyMode 'ClearSelectionMode', pane)
end)

local rename_workspace = wezterm.action_callback(function(window, pane, _)
  local current_workspace = wezterm.mux.get_active_workspace()
  window:perform_action(act.PromptInputLine {
      description = 'Rename current Workspace (' .. current_workspace .. '):',
      action = wezterm.action_callback(function(_, _, line)
        if line then
          wezterm.mux.rename_workspace(current_workspace, line)
        end
      end)
  }, pane)
end)

config.keys = {
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' }, },
  { key = '[', mods = 'LEADER', action = activate_copy_mode_without_selection, },
  { key = 'x', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false }, },
  { key = 'w', mods = 'LEADER', action = act.CloseCurrentTab { confirm = false }, },
  { key = 'w', mods = 'LEADER|CTRL', action = act.CloseCurrentPane { confirm = false }, },
  { key = 's', mods = 'META', action = act.SplitVertical { domain = 'CurrentPaneDomain' }, },
  { key = 'v', mods = 'META', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
  { key = 'z', mods = 'META', action = act.TogglePaneZoomState, },
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain', },
  { key = 'h', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  { key = 'l', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'h', mods = 'CTRL|META', action = act.MoveTabRelative(-1) },
  { key = 'l', mods = 'CTRL|META', action = act.MoveTabRelative(1) },
  { key = 'l', mods = 'LEADER', action = act.SendKey { key = 'l', mods = 'CTRL' } },
  { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration, },
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
  }, },
  { key = 'n', mods = 'LEADER|SHIFT', action = act.PromptInputLine {
      description = 'New workspace name:',
      action = wezterm.action_callback(function(_, _, line)
        if line then
          wezterm.mux.spawn_window { workspace = line }
          wezterm.mux.set_active_workspace(line)
        end
      end),
  }, },
  { key = 'r', mods = 'LEADER|SHIFT', action = rename_workspace }, 
  { key = 'r', mods = 'META', action = act.RotatePanes 'Clockwise', },
  { key = 'R', mods = 'META', action = act.RotatePanes 'CounterClockwise', },
  { key = 'q', mods = 'LEADER', action = act.QuitApplication },
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
  { key = 's', mods = 'LEADER|CTRL', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
  { key = 's', mods = 'LEADER|SHIFT', action = act.ShowLauncherArgs { flags = 'DOMAINS' } },
  { key = '=', mods = 'CTRL', action = act.ResetFontSize },
}

-- TODO
-- Consider using the Input select for switching workspaces
-- prettier tabs
-- Create a domain dynamically ? needs to be added to wezterm
-- Closing a workspace at once (not supported natively, lots of lua code cf. https://github.com/wezterm/wezterm/issues/3658, not worth it)
-- contribute to add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722

local copy_mode = nil
local search_mode = nil

if wezterm.gui then
  copy_mode = wezterm.gui.default_key_tables().copy_mode
  table.insert(
    copy_mode,
    {
      key = 'y',
      mods = 'CTRL',
      action = act.Multiple {
        act.CopyTo 'ClipboardAndPrimarySelection',
        act.ClearSelection,
        act.CopyMode 'Close',
      },
    }
  )
  table.insert(
    copy_mode,
    {
      key = 'y',
      mods = 'NONE',
      action = act.Multiple {
        act.CopyTo 'ClipboardAndPrimarySelection',
        act.CopyMode 'MoveToSelectionOtherEnd',
        act.ClearSelection,
        act.CopyMode 'ClearSelectionMode',
      },
    }
  )
  table.insert(
    copy_mode,
    { 
      key = 'n', 
      mods = 'NONE', 
      action = act.Multiple {
        act.CopyMode 'NextMatch', 
        act.CopyMode 'MoveToSelectionOtherEnd',
        act.CopyMode 'ClearSelectionMode',
      }
    }
  )
  table.insert(
    copy_mode,
    { 
      key = 'n', 
      mods = 'SHIFT', 
      action = act.Multiple {
        act.CopyMode 'PriorMatch', 
        act.CopyMode 'MoveToSelectionOtherEnd',
        act.CopyMode 'ClearSelectionMode',
      }
    }
  )
  -- table.insert(
  --   copy_mode,
  --   { key = 'Backspace', mods = 'NONE', action = act.CopyMode 'ClearPattern' }
  -- )
  table.insert(
    copy_mode,
    { 
      key = '/', 
      mods = 'NONE', 
      action = act.Multiple {
        act.CopyMode 'ClearPattern',
        act.CopyMode 'EditPattern'
      },
    }
  )
  -- TODO make a function for that
  -- table.insert(
  --   copy_mode,
  --   {
  --     key = '*',
  --     mods = 'NONE',
  --     action = TODO
  --   }
  -- )

  search_mode = wezterm.gui.default_key_tables().search_mode
  table.insert(
    search_mode,
    {
      key = 'c',
      mods = 'CTRL',
      action = act.Multiple {
        act.CopyMode 'ClearPattern',
        act.ClearSelection,
        act.CopyMode 'Close',
      },
    }
  )
  table.insert(
    search_mode,
    {
      key = 'w',
      mods = 'CTRL',
      action = act.CopyMode 'ClearPattern',
    }
  )

  table.insert(
    search_mode,
    {
      key = 'Enter',
      mods = 'NONE',
      action = act.Multiple {
        act.CopyMode 'AcceptPattern',
        act.CopyMode 'MoveToSelectionOtherEnd',
        act.CopyMode 'ClearSelectionMode',
      }
    }
  )
end

config.key_tables = {
  copy_mode = copy_mode,
  search_mode = search_mode
}

return config
