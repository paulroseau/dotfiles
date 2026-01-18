require('conform').setup({
  formatters_by_ft = {
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    go = { 'goimports', 'gofmt' },
    javascript = { 'prettierd' },
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    lua = { 'stylua' },
    markdown = { 'prettierd' },
    nix = { 'nixfmt' },
    python = { 'ruff_fix', 'ruff_format' },
    rust = { 'rustfmt' },
    terraform = { 'terraform_fmt' },
    toml = { 'prettierd' },
    typescript = { 'prettierd' },
    yaml = { 'prettierd' },
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
