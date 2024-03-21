local luasnip = require('luasnip')

local i = luasnip.insert_node
local fmt = require('luasnip.extras.fmt').fmt

luasnip.setup({
	link_children = true, -- allow to cycle back into child snippets
  enable_autosnippets = true, -- allow to specify snippets of the autosnippet type
})

local function jump_if_locally_jumpable(direction)
  return function()
    if luasnip.locally_jumpable(direction) then
      luasnip.jump(direction)
    end
  end
end

vim.keymap.set({"i", "s"}, "<C-n>", jump_if_locally_jumpable(1), {silent = true})
vim.keymap.set({"i", "s"}, "<C-p>", jump_if_locally_jumpable(-1), {silent = true})
vim.keymap.set({"i"}, "<C-x>", luasnip.expand)

local mark_down_code_block = luasnip.snippet(
  {
    trig = 'cb',
    snippetType = 'autosnippet',
  },
  fmt([[
  ```{}
  {}
  ```
  ]], {
    i(1, 'sh'),
    i(2, '...'),
  })
)

luasnip.add_snippets("markdown", {
  mark_down_code_block,
})
