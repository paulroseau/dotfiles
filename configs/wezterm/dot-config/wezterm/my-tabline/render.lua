local utils = require('my-tabline.utils')

local M = {}

local function surround_with_text(elements, text_left, text_right)
  local result = {}
  if text_left and text_left ~= "" then
    table.insert(result, { Text = text_left })
  end
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  if text_right and text_right ~= "" then
    table.insert(result, { Text = text_right })
  end
  return result
end

local function bold(elements)
  local result = {}
  table.insert(result, { Attribute = { Intensity = 'Bold' } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Intensity = 'Normal' } })
  return result
end

local function italic(elements)
  local result = {}
  table.insert(result, { Attribute = { Italic = true } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Italic = false } })
  return result
end

local function underline(elements, underline_style)
  local result = {}
  table.insert(result, { Attribute = { Underline = underline_style } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Underline = 'None' } })
  return result
end

local function foreground_color(elements, color, previous_color)
  local result = {}
  if not color or color == previous_color then
    return elements
  end
  table.insert(result, { Foreground = { Color = color } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Foreground = { Color = previous_color } })
  return result
end

function M.component(component, options, colors)
  local result = {}

  table.insert(result, { Background = { Color = colors.background } })
  table.insert(result, { Foreground = { Color = colors.foreground } })

  local icon = {}
  if component.icon and not options.text_only then
    icon = { { Text = component.icon } }
    icon = foreground_color(icon, component.icon_foreground_color, colors.foreground)
  end

  local text = {}
  if not options.icon_only then
    local text_content = component.text
    local max_text_width = options.max_text_width or 1000
    if string.len(text_content) > max_text_width then
      text_content = text_content:sub(1, max_text_width - 1) .. '…'
    end

    text = { { Text = text_content } }

    if options.italic then text = italic(text) end
    if options.bold then text = bold(text) end
    if options.underline then text = underline(text, options.underline) end
  end

  result = utils.concatenate(icon, text)

  if #result > 0 then
    result = surround_with_text(
      result,
      string.rep(' ', options.padding and options.padding.left or 0),
      string.rep(' ', options.padding and options.padding.right or 0)
    )
  end

  return result
end

function M.separator(separator, previous_background_color, next_background_color)
  local result = {}

  if separator ~= '' then
    table.insert(result, { Background = { Color = next_background_color } })
    table.insert(result, { Foreground = { Color = previous_background_color } })
    table.insert(result, { Text = separator })
  end

  return result
end

return M
