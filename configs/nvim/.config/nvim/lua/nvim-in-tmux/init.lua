local M = {}

local DEFAULT_CONFIG = {
  tmux = { 
    vim_mode_hook_id = 10, -- picked randomly, easiest way to add and remove one particular hook
    vim_option_name = nil,
  },
  nvim = {
    mappings_key =  {
      left = '<M-h>',
      down = '<M-j>',
      up = '<M-k>',
      right = '<M-l>',
    },
    augroup_name = "NvimInTmux",
  },
  do_preserve_zoomed_window = true,
  do_set_mappings = true,
}

local Direction = {
  LEFT = {
    vim = { key = "h" },
    tmux = { edge = "pane_at_left", flag = "-L", },
  },
  DOWN = {
    vim = { key = "j" },
    tmux = { edge = "pane_at_bottom", flag = "-D", },
  },
  UP = {
    vim = { key = "k" },
    tmux = { edge = "pane_at_top", flag = "-U", },
  },
  RIGHT = {
    vim = { key = "l" },
    tmux = { edge = "pane_at_right", flag = "-R", },
  },
}

local function set_nvim_in_tmux_augroup(config, tmux)
  nvim_in_tmux_augroup = vim.api.nvim_create_augroup(config.nvim.augroup_name, { clear = true })

  vim.api.nvim_create_autocmd({'VimEnter', 'VimResume'}, {
    callback = function ()
      tmux.set_vim_mode_hook_on_current_pane()
      tmux.set_vim_mode("on")
    end,
    group = nvim_in_tmux_augroup,
  })

  vim.api.nvim_create_autocmd({'VimLeave', 'VimSuspend'}, {
    callback = function()
      tmux.unset_vim_mode_hook_on_current_pane()
      tmux.set_vim_mode("off")
    end,
    group = nvim_in_tmux_augroup,
  })
end

local function change_nvim_window(config, tmux, direction)
  return function()
    local start_window = vim.fn.winnr()
    vim.cmd.wincmd(direction.vim.key)
    local end_window = vim.fn.winnr()

    if end_window ~= start_window then
      return
    elseif tmux.is_current_window_zoomed() and config.do_preserve_zoomed_window then
      return
    elseif tmux.is_current_pane_at(direction.tmux.edge) then
      return
    end

    tmux.set_vim_mode("off")
    tmux.select_pane(direction.tmux.flag)
  end
end

function M.setup(_config)
  local Nvim_In_Tmux = {}

  if not os.getenv("TMUX") then 
    vim.notify_once("nvim-in-tmux/init.lua needs to execute inside tmux", vim.log.levels.INFO)
    return nil
  end

  local tmux_vim_option_name = os.getenv("vim_mode_option")
  if not tmux_vim_option_name then
    vim.notify_once("nvim-in-tmux/init.lua needs tmux to define a 'vim_mode_option'", vim.log.levels.WARN)
    return nil
  end

  local config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, _config or {})
  config.tmux.vim_option_name = tmux_vim_option_name

  tmux = require("nvim-in-tmux.tmux").setup(config.tmux)

  set_nvim_in_tmux_augroup(config, tmux)

  function Nvim_In_Tmux.move_left()
    return change_nvim_window(config, tmux, Direction.LEFT)
  end

  function Nvim_In_Tmux.move_down()
    return change_nvim_window(config, tmux, Direction.DOWN)
  end

  function Nvim_In_Tmux.move_up()
    return change_nvim_window(config, tmux, Direction.UP)
  end

  function Nvim_In_Tmux.move_right()
    return change_nvim_window(config, tmux, Direction.RIGHT)
  end

  if config.do_set_mappings then
    vim.keymap.set({'n', 'v'} , config.nvim.mappings_key.left, Nvim_In_Tmux.move_left())
    vim.keymap.set({'n', 'v'} , config.nvim.mappings_key.down, Nvim_In_Tmux.move_down())
    vim.keymap.set({'n', 'v'} , config.nvim.mappings_key.up, Nvim_In_Tmux.move_up())
    vim.keymap.set({'n', 'v'} , config.nvim.mappings_key.right, Nvim_In_Tmux.move_right())
  end

  return Nvim_In_Tmux
end

return M
