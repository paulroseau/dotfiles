local luasnip = require('luasnip')

luasnip.setup({
	link_children = true, -- allow to cycle back into child snippet
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
