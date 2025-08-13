local grey_blue = '#3b4261'

return {
  default_options = {
    padding = { left = 1, right = 1 },
    icons_only = false,
    text_only = false,
    max_text_width = 10,
  },
  palette_overrides = {
    cursor_bg = grey_blue
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
        colors = {}
      },
      {
        components = {
          { name = 'workspace',                 options = {} },
          { name = 'current-working-directory', options = {} },
        },
        colors = {}
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
          { name = 'ram', options = {} },
          { name = 'cpu', options = {} },
        },
        colors = {}
      },
      {
        components = {
          { name = 'battery',  options = {} },
          { name = 'datetime', options = {} },
        },
        colors = {}
      },
    }
  },
  tabs = {
    separators = { left = '', right = '', },
    components = {
      -- process = { padding = { left = 1, right = 0 }, icons_only = true },
      { name = 'current-working-directory', options = { padding = { left = 0, right = 1 } } },
      -- zoomed = { padding = { left = 0, right = 0 } },
    },
  },
}

-- opts:
-- zero_indexed: tabs -> use config.tab_and_split_indices_are_zero_based
-- icon: output, process, zoomed, battery, cpu, ram datetime, domain
-- use_pwsh: cpu, ram -> don't configure (attribute of class) - need to check on windows
-- throttle: cpu, ram -> don't configure (attribute of class)
-- style: datetime    -> don't configure (attribute of class)
