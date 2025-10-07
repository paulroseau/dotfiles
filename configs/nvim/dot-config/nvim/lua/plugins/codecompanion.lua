local fzf = require('fzf-lua')

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

vim.api.nvim_create_user_command('CCChats', function()
  fzf.buffers({
    prompt = 'CC Chats> ',
    show_unlisted = true, -- CodeCompanion creates unlisted buffer with api.nvim_create_buf(false, true), it is not parametrizable
    ignore_current_buffer = true,
    query = '[CodeCompanion]',
    winopts = {
      title = 'Code Companion Chats',
      preview = {
        default = 'right:50%'
      },
    },
  })
end, {})
