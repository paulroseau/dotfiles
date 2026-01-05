local function enable_treesiter(buffer, language)
  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.treesitter.start(buffer, language)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter.setup', {}),
  callback = function(args)
    local buffer = args.buf
    local filetype = args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(language) then
      enable_treesiter(buffer, language)
    end
  end,
})
