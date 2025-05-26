local utils = require("nvim-smart-windows.utils")

local M = {}

local DEFAULT_CONFIG = {
  do_preserve_zoomed_pane = true,
}

function M.setup(config)
  local client = require("nvim-smart-windows.client." .. config.client.name).client(config.client)

  if client then
    utils.setup_augroup(config.augroup_name, client)
    utils.setup_commands(config, client)
    return true
  end
end

return M
