require('lualine').setup({
  options = {
    component_separators = { left = '╲', right = '╱'},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diagnostics'},
    lualine_c = {'buffers'},
    lualine_x = {''},
    lualine_y = {'filetype'},
    lualine_z = {'progress'},
  },
  -- unfortunately cannot use this for tabline
  -- https://github.com/nvim-lualine/lualine.nvim/pull/1013 to be merged and
  -- https://github.com/nvim-lualine/lualine.nvim/issues/1173 to be addressed
  tabline = {}, 
  extensions = {
   'quickfix',
  }
})
