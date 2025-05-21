require("gitmoji").setup({
  filetypes = { "gitcommit" },
  completion = {
    append_space = false,
    complete_as = "emoji",
  },
})

require("cmp").setup({
  sources = {
    { name = 'gitmoji' }
  }
})
