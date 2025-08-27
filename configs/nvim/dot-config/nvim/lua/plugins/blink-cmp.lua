local blink = require('blink.cmp')

-- Make all LSP clients communicate to LSP servers blink supported capabilities
-- NB: vim.lsp.config has __call set to expand exsisting settings, so this won't override previous settings for '*'
-- refer to runtime/lua/vim/lsp.lua
vim.lsp.config('*', {
  capabilities = blink.get_lsp_capabilities({}, true)
})

blink.setup({
  keymap = {
    preset = 'none',
    ['<C-j>'] = { 'insert_next' },
    ['<C-k>'] = { 'insert_prev' },
    ['<C-c>'] = { 'cancel', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<M-p>'] = { 'show_documentation', 'hide_documentation', },
    ['<M-e>'] = { 'scroll_documentation_up', 'fallback' },
    ['<M-d>'] = { 'scroll_documentation_down', 'fallback' },
  },

  completion = {
    ghost_text = {
      enabled = true,
    },
  },

  cmdline = {
    enabled = true,

    sources = function()
      -- Commands only (no autocomplete for '/' or '?' intentionally)
      local type = vim.fn.getcmdtype()
      if type == ':' or type == '@' then return { 'cmdline' } end
      return {}
    end,

    keymap = {
      preset = 'none',
      ['<C-j>'] = { 'insert_next' },
      ['<C-k>'] = { 'insert_prev' },
      ['<C-c>'] = { 'cancel', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-<CR>>'] = { 'accept_and_enter', 'fallback' },
    },

    completion = {
      menu = {
        auto_show = true,
      },
    },
  },

  signature = {
    -- use C-s to display the signature_help floating window from insert mode
    -- enable this only if you want the signature floating window to pop automatically on trigger characters
    enabled = false,
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },

    min_keyword_length = function(ctx)
      -- when typing a command, only show when the keyword is 3 characters or longer
      if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
      return 2
    end,

    per_filetype = {
      gitcommit = { 'gitmoji', 'path' },
      lua = { 'lazydev', 'lsp', 'snippets', 'path', 'buffer' },
    },

    providers = {
      lsp = {
        score_offset = 3,
      },

      snippets = {
        score_offset = 3,
      },

      path = {
        score_offset = 0,
      },

      buffer = {
        score_offset = -3,
      },

      gitmoji = {
        name = 'gitmoji',
        module = 'gitmoji.blink',
        score_offset = 100,
        opts = {
          filetypes = { 'gitcommit' },
          completion = {
            append_space = true,
            complete_as = 'emoji',
          },
        },
      },

      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
    },
  }
})
