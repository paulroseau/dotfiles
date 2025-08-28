local wezterm = require('wezterm')

local nvim_support = require('nvim-support')
local events = require('events')

local act = wezterm.action

local M = {}

-- Copy/Search mode
-- Need to bundle those in a function, wrapping those actions in act.Multiple the selection mode remains on
M.copy_mode_activate_no_selection = wezterm.action_callback(function(window, pane, _)
  window:perform_action(act.ActivateCopyMode, pane)
  window:perform_action(act.CopyMode 'MoveToSelectionOtherEnd', pane)
  window:perform_action(act.CopyMode 'ClearSelectionMode', pane)
end)

M.copy_mode_yank_and_exit = act.Multiple {
  act.CopyTo 'ClipboardAndPrimarySelection',
  act.ClearSelection,
  act.CopyMode 'Close',
}

M.copy_mode_yank = act.Multiple {
  act.CopyTo 'ClipboardAndPrimarySelection',
  act.CopyMode 'MoveToSelectionOtherEnd',
  act.ClearSelection,
  act.CopyMode 'ClearSelectionMode',
}

M.copy_mode_next_match = act.Multiple {
  act.CopyMode 'NextMatch',
  act.CopyMode 'MoveToSelectionOtherEnd',
  act.CopyMode 'ClearSelectionMode',
}

M.copy_mode_prior_match = act.Multiple {
  act.CopyMode 'PriorMatch',
  act.CopyMode 'MoveToSelectionOtherEnd',
  act.CopyMode 'ClearSelectionMode',
}

M.copy_mode_start_search = act.Multiple {
  act.CopyMode 'ClearPattern',
  act.CopyMode 'EditPattern',
}

M.search_mode_validate = act.Multiple {
  act.CopyMode 'AcceptPattern',
  act.CopyMode 'MoveToSelectionOtherEnd',
  act.CopyMode 'ClearSelectionMode',
}

-- TODO make a mapping for * in copy mode which searches word currently under cursor
M.copy_mode_search_current_word = nil

M.exit_copy_mode = act.Multiple {
  act.CopyMode 'ClearPattern',
  act.ClearSelection,
  act.CopyMode 'Close',
}

-- Workspaces
M.spawn_new_workspace = act.PromptInputLine {
  description = 'New workspace name:',
  action = wezterm.action_callback(function(window, pane, line)
    if line and line ~= "" then
      wezterm.mux.spawn_window { workspace = line }
      wezterm.mux.set_active_workspace(line)
      window:perform_action(act.EmitEvent(events.pane_focused_out), pane)
    end
  end),
}

M.rename_workspace = wezterm.action_callback(function(window, pane, _)
  local current_workspace = wezterm.mux.get_active_workspace()
  window:perform_action(act.PromptInputLine {
    description = 'Rename current Workspace ("' .. current_workspace .. '"):',
    action = wezterm.action_callback(function(_, _, line)
      if line then
        wezterm.mux.rename_workspace(current_workspace, line)
      end
    end)
  }, pane)
end)

-- Tabs
M.spawn_tab = events.act_then_fire_focused_out_event(
  act.SpawnTab 'CurrentPaneDomain'
)

M.close_current_tab = events.act_then_fire_focused_out_event(
  act.CloseCurrentTab { confirm = false }
)

function M.activate_tab_relative(offset)
  return events.act_then_fire_focused_out_event(
    act.ActivateTabRelative(offset)
  )
end

M.rename_tab = wezterm.action_callback(function(window, pane, _)
  local current_tab_title = window:active_tab():get_title()
  window:perform_action(act.PromptInputLine {
    description = 'Rename tab ("' .. current_tab_title .. '"):',
    action = wezterm.action_callback(function(window, pane, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  }, pane)
end)

-- Panes
M.move_pane_to_new_tab = wezterm.action_callback(function(window, pane)
  local tab, _ = pane:move_to_new_tab()
  tab:activate()
end)

M.send_pane_to_new_tab = events.act_then_fire_focused_out_event(
  wezterm.action_callback(function(window, pane) pane:move_to_new_tab() end)
)

M.close_current_pane = events.act_then_fire_focused_out_event(
  act.CloseCurrentPane { confirm = false }
)

function M.activate_pane_direction(args)
  return events.act_then_fire_focused_out_event(
    act.ActivatePaneDirection(args)
  )
end

function M.split_pane(args)
  return events.act_then_fire_focused_out_event(
    act.SplitPane(args)
  )
end

-- Appearance

M.select_color_scheme = wezterm.action_callback(function(window, pane, _)
  local input_selector_callback = wezterm.action_callback(
    function(window, pane, id, label)
      if label then
        local config_overrides = window:get_config_overrides() or {}
        config_overrides.color_scheme = label
        window:set_config_overrides(config_overrides)
      end
    end
  )

  window:perform_action(
    act.InputSelector {
      title = 'Switch color scheme',
      choices = {
        { label = 'Tokyo Night' },
        { label = 'Tokyo Night Day' },
        { label = 'Tokyo Night Moon' },
        { label = 'Tokyo Night Storm' },
        { label = 'Onedark' },
        { label = 'Solarized (dark) (terminal.sexy)' },
        { label = 'Solarized (light) (terminal.sexy)' },
      },
      action = input_selector_callback,
      fuzzy = true,
      fuzzy_description = 'Select scheme: ',
    },
    pane
  )
end)

return M
