local M = {}

local function at_right_edge()
  return vim.fn.winnr() == vim.fn.winnr('l')
end

local function at_bottom_edge()
  return vim.fn.winnr() == vim.fn.winnr('j')
end

local opposite_resize_key = {
  ['+'] = '-',
  ['-'] = '+',
  ['<'] = '>',
  ['>'] = '<',
}

local Direction = {
  right = { nvim_key = 'l' },
  down = { nvim_key = 'j' }
}

local function resize_window(nvim_key, count)

  -- resize the currently selected window
  local function resize_current_window(opts)
    vim.cmd.wincmd { args = { (opts.use_opposite_key and opposite_resize_key[nvim_key]) or nvim_key }, count = count }
  end

  -- resize the currently selected window and returns whether its position moved
  local function current_window_moved_after_resize(opts)
    local window_position = vim.api.nvim_win_get_position(0)
    resize_current_window(opts)
    local window_new_position = vim.api.nvim_win_get_position(0)
    return window_position[1] ~= window_new_position[1] or window_position[2] ~= window_new_position[2]
  end

  local function try_resizing_adjacent_window(win_id, direction)
    -- move to adjacent window (at the right or the bottom)
    vim.cmd.wincmd(direction.nvim_key)

    -- perform the opposite action on the adjacent window (below or to the right)
    -- if its position moves then that means we could move the targeted border (right border or bottom border) on the initial window
    local common_border_moved = current_window_moved_after_resize({ use_opposite_key = true })

    if not common_border_moved then
      -- no luck let's undo what we just did
      resize_current_window({})
    end

    -- move back to original window
    vim.api.nvim_set_current_win(win_id)
    return common_border_moved
  end

  local is_horizontal_resize = nvim_key == '<' or nvim_key == '>'
  local is_vertical_resize = nvim_key == '+' or nvim_key == '-'

  local at_edge = at_bottom_edge
  local direction = Direction.down

  if is_horizontal_resize then
    at_edge = at_right_edge
    direction = Direction.right
  end

  return function()
    if at_edge() then
      return resize_current_window({ use_opposite_key = true })
    end

    if current_window_moved_after_resize({}) then
      -- the top left corner position moved which means the top or left border was moved
      -- let's move to the window below or to the right and try to perform the opposite action to see if this would move the right or bottom border of this window
      if try_resizing_adjacent_window(vim.fn.win_getid(), direction) then
        -- the adjacent window has been resized to get the expected effect on this window, let's undo what we had done previously on this window
        resize_current_window({ use_opposite_key = true })
      end
    end
  end
end

function M.left(increment) return resize_window('<', increment) end
function M.down(increment) return resize_window('+', increment) end
function M.up(increment) return resize_window('-', increment) end
function M.right(increment) return resize_window('>', increment) end

return M
