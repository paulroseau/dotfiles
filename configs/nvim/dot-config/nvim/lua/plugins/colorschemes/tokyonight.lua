require("tokyonight").setup({
  style = "moon", -- `storm`, `moon`, `night` and `day`
  light_style = "day", -- theme used when the background is set to light
  transparent = false,
  keywords = { italic = true },

  on_colors = function(colors)
    colors.fg = "#a8aecb" -- default is "too white"
  end,

  on_highlights = function(highlights, colors)
    highlights["@module"] = { link = "Identifier" } -- default is Include which makes imports hard to see since imports also links to Include
  end,
})
