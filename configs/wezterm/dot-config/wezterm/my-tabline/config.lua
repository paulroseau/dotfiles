local M = {}

local default_color_scheme = 'Tokyo Night Storm'

local config = {
  default_options = {
    padding = { left = 1, right = 1 },
    icons_only = false,
    text_only = false,
    max_text_width = 10,
  },
  left_status = {
    separators = {
      primary = '',
      secondary = '╲'
    },
    sections = {
      { components = { domain = {}, }, },
      { components = { workspace = {}, }, }
    },
  },
  right_status = {
    separators = {
      primary = '',
      secondary = '╱'
    },
    sections = {
      { components = { ram = {}, cpu = {} }, },
      { components = { battery = {}, datetime = {} }, }
    }
  },
  tabs = {
    separators = { left = '', right = '', },
    components = {
      ['process'] = { padding = { left = 1, right = 0 }, icons_only = true },
      ['cwd'] = { padding = { left = 0, right = 1 } },
      ['zoomed'] = { padding = { left = 0, right = 0 } },
    },
  },
  colors = require('wezterm').color.get_builtin_schemes()[default_color_scheme]
}

function M.set_colors(color_scheme)
  if type(color_scheme) == "string" then
    config.colors = require('wezterm').color.get_builtin_schemes()[color_scheme]
  else
    config.colors = color_scheme
  end
end

return setmetatable(M, {
  __index = config,
  __newindex = function(t, k, v) error('Config is read-only, use set_* methods to update', 2) end
})

-- opts:
-- zero_indexed: tabs -> use config.tab_and_split_indices_are_zero_based
-- icon: output, process, zoomed, battery, cpu, ram datetime, domain
-- use_pwsh: cpu, ram -> don't configure (attribute of class) - need to check on windows
-- throttle: cpu, ram -> don't configure (attribute of class)
-- style: datetime    -> don't configure (attribute of class)
