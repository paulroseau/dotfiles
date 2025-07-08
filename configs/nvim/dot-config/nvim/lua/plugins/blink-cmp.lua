local blink = require('blink.cmp')

-- Make all LSP clients communicate to LSP servers blink supported capabilities
-- NB: vim.lsp.config has __call set to expand exsisting settings, so this won't override previous settings for '*'
-- refer to runtime/lua/vim/lsp.lua
vim.lsp.config('*', {
  capabilities = blink.get_lsp_capabilities({}, true)
})

blink.setup({
  keymap = {
    ['<C-j>'] = { 'insert_next' },
    ['<C-k>'] = { 'insert_prev' },
    ['<C-c>'] = { 'cancel', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<M-p>'] = { 'show_documentation', 'hide_documentation', },
    ['<M-e>'] = { 'scroll_documentation_up', 'fallback' },
    ['<M-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<C-s>'] = { 'show_signature', 'hide_signature', 'fallback' }
  },

  completion = {
    ghost_text = {
      enabled = true,
    },
  },

  cmdline = {
    enabled = true,

    sources = function()
      local type = vim.fn.getcmdtype()
      -- Commands (only - no autocomplete for '/' or '?' intentionally)
      if type == ':' or type == '@' then return { 'cmdline' } end
      return {}
    end,

    keymap = {
      ['<C-j>'] = { 'insert_next' },
      ['<C-k>'] = { 'insert_prev' },
      ['<C-c>'] = { 'cancel', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<S-<CR>>'] = { 'accept_and_enter', 'fallback' },
    },

    completion = {
      menu = {
        auto_show = true,
      },
    },
  },

  signature = {
    enabled = true,
    trigger = {
      enabled = false,
      show_on_keyword = false,
      show_on_trigger_character = false,
      show_on_insert = false,
      show_on_insert_on_trigger_character = false,
    },
  },

  sources = {

    default = { 'lsp', 'path', 'snippets', 'buffer' },

    min_keyword_length = function(ctx)
      -- when typing a command, only show when the keyword is 3 characters or longer
      if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
      return 2
    end,

    per_filetype = {
      gitcommit = { 'gitmoji', 'path', 'buffer' },
      lua = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    },

    providers = {
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
