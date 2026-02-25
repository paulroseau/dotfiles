require('conform').setup({
  formatters_by_ft = {
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    go = { 'goimports', 'gofmt' },
    javascript = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    lua = { 'stylua' },
    markdown = { 'prettier' },
    nix = { 'nixfmt' },
    python = { 'ruff_fix', 'ruff_format' },
    rust = { 'rustfmt' },
    terraform = { 'terraform_fmt' },
    toml = { 'prettier' },
    typescript = { 'prettier' },
    yaml = { 'prettier' },
    ['_'] = { 'trim_newlines', 'trim_whitespace' },
  },
  default_format_opts = {
    lsp_format = 'fallback',
  },
  format_on_save = {
    timeout_ms = 500,
  },
  notify_on_error = true,
  notify_no_formatters = true,
})
