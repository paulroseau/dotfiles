local tmux = require("nvim-tmux.tmux")
local utils = require("nvim-tmux.utils")

local M = {}

local DEFAULT_CONFIG = {
  tmux = { 
    vim_mode_hook_id = 10, -- picked randomly, easiest way to add and remove one particular hook
    vim_option_name = nil,
  },
  augroup_name = "NvimTmux",
  do_preserve_zoomed_window = true,
}

function M.setup(_config)
  if not os.getenv("TMUX") then 
    vim.notify_once("nvim-tmux needs to execute inside tmux", vim.log.levels.WARN)
    return nil
  end

  local tmux_vim_option_name = os.getenv("vim_mode_option")
  if not tmux_vim_option_name then
    -- TODO log properly the file where this fails
    vim.notify_once("nvim-tmux needs tmux to define 'vim_mode_option'", vim.log.levels.WARN)
    return nil
  end

  local config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, _config or {})
  config.tmux.vim_option_name = tmux_vim_option_name
  local pane_id = tmux.get_current_pane_id()

  local tmux_client = tmux.client(config.tmux, pane_id)
  utils.setup_augroup(config.augroup_name, tmux_client)
  utils.setup_commands(config, tmux_client)

  return true
end

return M
