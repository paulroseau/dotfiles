local wezterm = require('wezterm')

local M = {}

local Component = {}

function Component:new(_args)
  local instance = _args or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Component:render(icon_only, text_only, section_foreground, padding_left, padding_right)
  local result = {}

  if self.icon and not text_only then
    if self.icon.color_foreground then
      table.insert(result, { Foreground = { Color = self.icon.color_foreground } })
      table.insert(result, { Text = self.icon.value })
      table.insert(result, { Foreground = { Color = section_foreground } })
    else
      table.insert(result, { Text = self.icon.value })
    end
  end

  if not icon_only then
    if self.text.color_foreground then
      table.insert(result, { Foreground = { Color = self.text.color_foreground } })
      table.insert(result, { Text = self.text.value })
      table.insert(result, { Foreground = { Color = section_foreground } })
    else
      table.insert(result, { Text = self.text.value })
    end
  end

  if #result > 0 then
    if padding_left > 0 then table.insert(result, 0, { Text = string.rep(' ', padding_left) }) end
    if padding_right > 0 then table.insert(result, { Text = string.rep(' ', padding_right) }) end
  end

  return result
end

local Components = {
  ['cwd'] = function(window, tab)
    local cwd_uri = tab.active_pane.current_working_dir
    if cwd_uri then
      local file_path = cwd_uri.file_path
      return file_path:match('([^/]+)/?$')
    end
    return ''
  end

}

local Section = {}

function Section:new(_args)
  local instance = _args or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Section.elements(self)
  local result = {
    { Background = { Color = self.color.background } },
    { Foreground = { Color = self.color.default_foreground } },
    { Attribute = { Intensity = self.intensity or 'Normal', } },
    { Attribute = { Italic = self.italic or false, } },
    { Attribute = { Underline = self.underline or 'None', } },
  }

  for index, component in pairs(self.components) do
    local status_elements = component.render(self.icon_only, self.text_only, self.color.default_foreground)
    table.insert(result, elements)
    if index ~= #component then
      table.insert(result, { Text = self.component_separator })
    end
  end

  return result
end

function M.setup(opts)
  wezterm.on('update-status', function(window)
    window:set_left_status(wezterm.format(M.section(config.left, true)))
    window:set_right_status(wezterm.format(M.section(config.right, false)))
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    return require('tabline-rework.tabs').set_title(tab, hover)
  end)
end

return M
