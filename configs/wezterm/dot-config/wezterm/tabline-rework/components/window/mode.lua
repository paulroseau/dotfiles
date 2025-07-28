local M = {}

local modes = {
  ['copy_mode'] = 'COPY',
  ['normal_mode'] = 'NORMAL',
  ['search_mode'] = 'SEARCH',
}

function M.update(window)
  return modes[M.get(window)]
end

function M.get(window)
  local key_table = window:active_key_table()

  if modes[key_table] then
    return key_table
  end

  return 'normal_mode'
end

return M
