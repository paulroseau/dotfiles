require('codecompanion').setup({
  display = {
    action_palette = {
      provider = 'fzf_lua',
    }
  },

  strategies = {
    chat = { adapter = 'openai' },
    inline = { adapter = 'openai' },
  },

  adapters = {
    http = {
      openai = function()
        return require('codecompanion.adapters').extend('openai', {
          schema = {
            model = {
              default = 'gpt-5',
            }
          }

        })
      end,
    }
  },
})
