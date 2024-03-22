require('lualine').setup({
  options = {
    component_separators = { left = '╲', right = '╱'},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {''},
    lualine_y = {'filetype'},
    lualine_z = {'progress'},
  },
})
