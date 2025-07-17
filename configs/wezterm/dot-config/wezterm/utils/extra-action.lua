local wezterm = require('wezterm')

local nvim_support = require('utils.nvim-support')
local events = require('utils.event')

local act = wezterm.action

local M = {}

local function act_then_fire_event(args)
  return wezterm.action_callback(function(window, pane, _)
    local current_pane_id = pane:pane_id()

    local fire_pane_focused_in_event = wezterm.action_callback(function(window, new_pane, _)
      if new_pane:pane_id() ~= current_pane_id then
        window:perform_action(wezterm.action.EmitEvent(args.event), new_pane)
      end
    end)

    window:perform_action(args.action, pane)
    window:perform_action(fire_pane_focused_in_event, pane)
  end)
end

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
  act.CopyMode 'EditPattern'
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

-- Workspace
M.spawn_new_workspace = act.PromptInputLine {
  description = 'New workspace name:',
  action = wezterm.action_callback(function(window, pane, line)
    if line and line ~= "" then
      wezterm.mux.spawn_window { workspace = line }
      wezterm.mux.set_active_workspace(line)
      window:perform_action(act.EmitEvent(events.pane_focused_in), pane)
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

local function workspace_choices(current_window)
  local workspaces = {}
  local workspace = ""

  for _, window in pairs(wezterm.mux.all_windows()) do
    workspace = window:get_workspace()
    workspaces[workspace] = false
  end

  local current_workspace = current_window:mux_window():get_workspace()
  workspaces[current_workspace] = true

  local choices = {}

  for workspace, is_current in pairs(workspaces) do
    local choice = workspace
    if is_current then
      choice = choice .. ' (active)'
    end
    table.insert(choices, { label = choice })
  end

  return choices
end

M.select_workspace = wezterm.action_callback(function(window, pane, _)
  local choices = workspace_choices(window)

  local input_selector_callback = wezterm.action_callback(
    function(window, pane, id, label)
      if label and not label:find("(active)") then
        window:perform_action(act_then_fire_event {
          action = act.SwitchToWorkspace { name = label },
          event = events.pane_focused_in,
        }, pane)
      end
    end
  )

  window:perform_action(
    act.InputSelector {
      title = 'Workspace Selector',
      choices = choices,
      action = input_selector_callback,
      fuzzy = true,
      fuzzy_description = 'Select workspace: '
    },
    pane
  )
end)

-- Windows

-- Tabs
M.spawn_tab = act_then_fire_event {
  action = act.SpawnTab 'CurrentPaneDomain',
  event = events.pane_focused_in
}

M.close_current_tab = act_then_fire_event {
  action = act.CloseCurrentTab { confirm = false },
  event = events.pane_focused_in
}

function M.activate_tab_relative(offset)
  return act_then_fire_event {
    action = act.ActivateTabRelative(offset),
    event = events.pane_focused_in
  }
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

M.send_pane_to_new_tab = act_then_fire_event {
  action = wezterm.action_callback(function(window, pane) pane:move_to_new_tab() end),
  event = events.pane_focused_in
}

M.close_current_pane = act_then_fire_event {
  action = act.CloseCurrentPane { confirm = false },
  event = events.pane_focused_in
}

function M.activate_pane_direction(args)
  return act_then_fire_event {
    action = act.ActivatePaneDirection(args),
    event = events.pane_focused_in
  }
end

function M.split_pane(args)
  return act_then_fire_event {
    action = act.SplitPane(args),
    event = events.pane_focused_in
  }
end

M.toggle_ignore_nvim_running_flag = wezterm.action_callback(function(window, pane)
  nvim_support.toggle_ignore_nvim_running_flag()
end)

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
