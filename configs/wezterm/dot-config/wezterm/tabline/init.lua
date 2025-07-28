-- Credits to https://github.com/michaelbrusegard/tabline.wez

local wezterm = require('wezterm')

local M = {}

function M.setup(opts)
  require('tabline.config').set(opts)

  wezterm.on('update-status', function(window)
    toto = {
      { Foreground = { Color = 'blue' } },
      { Background = { Color = 'white' } },
      { Text = 'hello ' },
      { Foreground = { Color = 'red' } },
      { Text = 'red' },
    }
    -- window:set_left_status(wezterm.format(toto))
    require('tabline.component').set_status(window)
  end)

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
    return require('tabline.tabs').set_title(tab, hover)
  end)
end

return M
