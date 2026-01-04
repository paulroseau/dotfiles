local M = {}

function M.add_child_directories_to_rtp(parent_path)
  if not vim.loop.fs_stat(parent_path) then
    vim.notify_once("Plugin directory " .. parent_path .. " does not exist",
      vim.log.levels.WARN)
    return nil
  end

  for name in vim.fs.dir(parent_path) do
    local plugin_path = parent_path .. "/" .. name

    -- Can't use:
    -- name, type = vim.fs.dir(parent_path)
    -- because `type` shows "file" for links even though they point to a directory
    local type = vim.loop.fs_stat(plugin_path).type

    if type ~= "directory" then
      vim.notify("Warn: " .. plugin_path .. " is not added to rtp since it is not a directory", vim.log.levels.WARN)
    else
      vim.opt.runtimepath:prepend(plugin_path)
    end
  end
end

return M
