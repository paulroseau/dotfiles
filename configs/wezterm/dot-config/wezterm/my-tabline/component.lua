local Component = {}

function Component:new(text, icon, foreground_color)
  local instance = {
    text = text,
    icon = icon,
    foreground_color = foreground_color,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Component:render(options, colors)
  local result = {}

  table.insert(result, { Background = { Color = colors.background } })

  if self.foregroud_color then
    table.insert(result, { Foreground = { Color = self.foreground_color } })
  else
    table.insert(result, { Foreground = { Color = colors.foreground } })
  end

  if self.icon and not options.text_only then
    table.insert(result, { Text = self.icon.value })
  end

  if not options.icon_only then
    local text = self.text
    if text > options.max_length then
      text = text:sub(1, options.max_length - 1) .. '…'
    end

    table.insert(result, { Text = text })
  end

  if #result > 0 then
    if options.padding and options.padding.left > 0 then
      table.insert(result, 0, { Text = string.rep(' ', options.padding.left) })
    end
    if options.padding and options.padding.right > 0 then
      table.insert(result, { Text = string.rep(' ', options.padding.right) })
    end
  end

  return result
end

return Component
