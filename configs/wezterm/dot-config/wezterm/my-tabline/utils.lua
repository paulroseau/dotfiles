local M = {}

function M.deep_extend(t1, t2)
  local result = {}

  for k, v in pairs(t1) do
    result[k] = v
  end

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

function M.flatten(arrays, separator)
  local result = {}
  local is_first = true

  for _, array in ipairs(arrays) do
    if not is_first and #array > 0 then
      table.insert(result, separator)
    end

    for _, value in ipairs(array) do
      table.insert(result, value)
    end

    if is_first then
      is_first = false
    end
  end

  return result
end

function M.reverse(t)
  local result = {}
  for _, elem in ipairs(t) do
    table.insert(result, 1, elem)
  end
  return result
end

return M
