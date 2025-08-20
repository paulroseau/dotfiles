local utils = require('my-tabline.utils')

local M = {}

function M.make_text(str)
  return str and { Text = str } or {}
end

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

local function make_bold(elements)
  if #elements == 0 then return elements end

  local result = {}
  table.insert(result, { Attribute = { Intensity = 'Bold' } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Intensity = 'Normal' } })
  return result
end

local function make_italic(elements)
  if #elements == 0 then return elements end

  local result = {}
  table.insert(result, { Attribute = { Italic = true } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Italic = false } })
  return result
end

local function change_underline_style(elements, underline_style)
  if #elements == 0 then return elements end

  local result = {}
  table.insert(result, { Attribute = { Underline = underline_style } })
  for _, element in ipairs(elements) do
    table.insert(result, element)
  end
  table.insert(result, { Attribute = { Underline = 'None' } })
  return result
end

local function change_foreground_color(elements, color, previous_color)
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
  local icon = {}
  if not options.text_only and component.icon then
    icon = { M.make_text(component.icon) }
    icon = change_foreground_color(icon, component.icon_foreground_color, colors.foreground)
  end

  local text = {}
  if not options.icon_only and component.text then
    local text_content = component.text
    local max_text_width = options.max_text_width or 1000
    if string.len(text_content) > max_text_width then
      text_content = text_content:sub(1, max_text_width - 1) .. '…'
    end

    text = { M.make_text(text_content) }

    if options.italic then text = make_italic(text) end
    if options.bold then text = make_bold(text) end
    if options.underline then text = change_underline_style(text, options.underline) end
  end

  local result = utils.flatten({ icon, text }, M.make_text(' '))

  if #result > 0 then
    result = surround_with_text(
      result,
      string.rep(' ', options.padding and options.padding.left or 0),
      string.rep(' ', options.padding and options.padding.right or 0)
    )

    table.insert(result, 1, { Background = { Color = colors.background } })
    table.insert(result, 1, { Foreground = { Color = colors.foreground } })
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
