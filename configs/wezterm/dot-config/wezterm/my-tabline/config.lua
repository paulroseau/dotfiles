local palette = require('my-tabline.palette')

local M = {}

-- NB: we can't depend on `is_hover` in the background function because this information is not in the format-tab-title callback
-- tab_info, hence we can't know if the tab on the left/right is hovered on from
-- tabs_info -- and build the separator with the proper colors
local tab_default_colors = {
  foreground = function(is_active, is_hover, tab_index)
    if is_active then
      return palette.foreground
    elseif is_hover then
      return palette.magenta
    end
    return palette.current_mode
  end,
  background = function(is_active, tab_index)
    return (is_active and palette.background) or palette.surface
  end
}

local rainbow = {
  palette.magenta,
  palette.blue,
  palette.green,
  palette.yellow,
  palette.red,
}

local tab_rainbow_colors = {
  foreground = function(is_active, is_hover, tab_index)
    if is_active then
      return palette.foreground
    end
    return palette.cursor_bg or palette.black
  end,
  background = function(is_active, tab_index)
    if is_active then
      return palette.background
    end
    return rainbow[math.fmod(tab_index - 1, #rainbow) + 1]
  end
}

local config = {
  default_options = {
    padding = { left = 1, center = 1, right = 1, },
    text_only = false,
    icon_only = false,
    max_text_width = 10,
  },
  left_status = {
    separators = {
      primary = '',
      secondary = '╲'
    },
    sections = {
      {
        components = {
          { name = 'domain', options = { bold = true } },
        },
        colors = {
          foreground = function() return palette.background end,
          background = function() return palette.current_mode end,
        }
      },
      {
        components = {
          { name = 'workspace', options = {} },
        },
        colors = {
          foreground = function() return palette.current_mode end,
          background = function() return palette.surface end,
        }
      }
    },
  },
  right_status = {
    separators = {
      primary = '',
      secondary = '╱'
    },
    sections = {
      {
        components = {
          { name = 'ram' },
          { name = 'cpu' },
        },
        colors = {
          foreground = function() return palette.current_mode end,
          background = function() return palette.surface end,
        }
      },
      {
        components = {
          { name = 'battery' },
          { name = 'datetime' },
        },
        colors = {
          foreground = function() return palette.background end,
          background = function() return palette.current_mode end,
        }
      },
    }
  },
  tabs = {
    separator = '',
    components = {
      {
        name = 'process',
        options = {
          icon_only = true,
          padding = { left = 1, right = 1 }
        }
      },
      {
        name = 'current-working-directory',
        options = {
          padding = { left = 0, right = 1 }
        }
      },
      {
        name = 'zoomed',
        options = {
          padding = { left = 0, right = 1 },
          icon_only = true
        },
      }
    },
    colors = tab_rainbow_colors,
    options = function(is_active, is_hover, tab_index)
      if is_active then
        return { bold = true }
      elseif is_hover then
        return {}
      end
      return { italic = true }
    end
  },
  extra = {}
}

function M.set_extra(key, value)
  config.extra[key] = value
end

return setmetatable(M, {
  __index = function(table, key)
    if config[key] then
      return config[key]
    end
    return config.extra[key]
  end,
  __newindex = function(table, key, value)
    local message = 'Error: tried to set "' .. key .. ' = ' .. value .. '" on my-tabline.config but it is read-only.\n'
    message = message .. 'Use set_extra method to add extra fields to config.'
    error(message, 2)
  end
})

-- opts:
-- zero_indexed: tabs -> use config.tab_and_split_indices_are_zero_based
-- icon: output, process, zoomed, battery, cpu, ram datetime, domain
-- use_pwsh: cpu, ram -> don't configure (attribute of class) - need to check on windows
-- throttle: cpu, ram -> don't configure (attribute of class)
-- style: datetime    -> don't configure (attribute of class)
