local M = {}

local function is_window_at_edge(move_out_key)
  return function()
    local win_id = vim.fn.win_getid()
    vim.cmd.wincmd(move_out_key)
    local new_win_id = vim.fn.win_getid()
    if win_id == new_win_id then
      return true
    end

    vim.api.nvim_set_current_win(win_id)
    return false
  end
end

local is_window_at_bottom = is_window_at_edge('j')
local is_window_at_right = is_window_at_edge('l')

local opposite_resize_key = {
  ['+'] = '-',
  ['-'] = '+',
  ['<'] = '>',
  ['>'] = '<',
}

local function resize_window(nvim_key)
  return function()
    if is_window_at_right() and (nvim_key == '<' or nvim_key == '>') then
      vim.cmd.wincmd(opposite_resize_key[nvim_key])
      return true
    end

    if is_window_at_bottom() and (nvim_key == '+' or nvim_key == '-') then
      vim.cmd.wincmd(opposite_resize_key[nvim_key])
      return true
    end

    vim.cmd.wincmd(nvim_key)
    return false
  end
end

function M.setup()
  vim.api.nvim_create_user_command('ResizeWinLeft', resize_window('<'), {})
  vim.api.nvim_create_user_command('ResizeWinDown', resize_window('+'), {})
  vim.api.nvim_create_user_command('ResizeWinUp', resize_window('-'), {})
  vim.api.nvim_create_user_command('ResizeWinRight', resize_window('>'), {})
end

return M
