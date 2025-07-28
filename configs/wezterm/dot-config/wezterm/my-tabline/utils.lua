local M = {}

function M.deep_extend(t1, t2)
  local result = {}
  for k, v in pairs(t2) do
    if type(v) == 'table' and type(t1[k] or false) == 'table' then
      local merged = M.deep_extend(t1[k], t2[k])
      result[k] = merged
    else
      result[k] = v
    end
  end
  return result
end

function M.concatenate(arrays, separator)
  local result = {}
  local is_first = true
  for _, array in ipairs(arrays) do
    for _, value in ipairs(array) do
      result.insert(value)
    end
    if is_first then
      is_first = false
    else
      result.insert(separator)
    end
  end
  return result
end

return M
