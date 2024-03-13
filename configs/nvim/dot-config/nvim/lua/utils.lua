local M = {}

local function get_new_plugin_rtp_insertion_indexes(rtp)
  local user_config_directory = vim.fn.stdpath("config")

  local user_config_directory_rtp_index = nil
  local user_config_after_directory_rtp_index = nil

  for index, directory in ipairs(rtp) do
    if directory == user_config_directory then
      user_config_directory_rtp_index = index
    end
    if directory == user_config_directory .. "/after" then
      user_config_after_directory_rtp_index = index
    end
  end
  return
    (user_config_directory_rtp_index + 1) or 1,
    user_config_after_directory_rtp_index or (#rtp + 1)
end

-- Insert plugins after ~/.config/nvim and in reverse order before
-- ~/.config/nvim/after for their ./after sub-directories
function M.add_child_directories_to_rtp(parent_path)
  if not vim.loop.fs_stat(parent_path) then
    vim.notify_once("Plugin directory " .. parent_path .. " does not exist, no external plugins loaded", vim.log.levels.WARN)
    return nil
  end

  local rtp = vim.opt.rtp:get()
  local insert_plugin_index, insert_plugin_after_index = get_new_plugin_rtp_insertion_indexes(rtp)

  for name in vim.fs.dir(parent_path) do
    local plugin_path = parent_path .. "/" .. name

    -- Can't use:
    -- name, type = vim.fs.dir(parent_path)
    -- because `type` shows "file" for links even though they point to a directory
    local type = vim.loop.fs_stat(plugin_path).type

    if type ~= "directory" then
      vim.notify("Warn: " .. plugin_path .. " is not added to rtp since it is not a directory", vim.log.levels.WARN)
    else
      table.insert(rtp, insert_plugin_index, plugin_path)
      insert_plugin_index = insert_plugin_index + 1
      insert_plugin_after_index = insert_plugin_after_index + 1
      local plugin_after_path = plugin_path .. "/after"
      if vim.loop.fs_stat(plugin_after_path) then
        table.insert(rtp, insert_plugin_after_index, plugin_after_path)
      end
    end
  end

  vim.opt.rtp = rtp
end

return M
