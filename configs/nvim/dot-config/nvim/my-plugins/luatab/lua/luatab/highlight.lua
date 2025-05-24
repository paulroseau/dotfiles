-- Shamelessly stolen from
-- https://github.com/hoob3rt/lualine.nvim/blob/master/lua/lualine/utils/utils.lua

local M = {}

local function do_highlight(name, foreground, background)
  local command = {'highlight', name}
  if foreground and foreground ~= 'none' then
    table.insert(command, 'guifg=' .. foreground)
  end
  if background and background ~= 'none' then
    table.insert(command, 'guibg=' .. background)
  end
  vim.cmd(table.concat(command, ' '))
end

function M.create_component_highlight_group(color, highlight_tag)
  if color.bg and color.fg then
    local highlight_group_name = table.concat({'luatab', highlight_tag}, '_')
    do_highlight(highlight_group_name, color.fg, color.bg)
    return highlight_group_name
  end
end

function M.extract_colors(color_group, scope)
  if vim.fn.hlexists(color_group) == 0 then return nil end
  local color = vim.api.nvim_get_hl(0, { name = color_group })
  if color.bg then
    color.bg = string.format('#%06x', color.bg)
  end
  if color.fg then
    color.fg = string.format('#%06x', color.fg)
  end
  if scope then return color[scope] end
  return color
end

return M
