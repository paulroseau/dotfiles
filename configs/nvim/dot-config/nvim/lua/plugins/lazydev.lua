require('lazydev').setup({
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
  enabled = function(root_dir)
    if vim.uv.fs_stat(root_dir .. "/.luarc.json") then return false end
    if vim.uv.fs_stat(root_dir .. "/.luarc.jsonc") then return false end
    return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
})
