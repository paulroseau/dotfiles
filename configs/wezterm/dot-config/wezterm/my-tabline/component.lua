local M = {}

function M.new(text, icon, icon_foreground_color)
  return {
    text = text,
    icon = icon,
    icon_foreground_color = icon_foreground_color,
  }
end

return M
