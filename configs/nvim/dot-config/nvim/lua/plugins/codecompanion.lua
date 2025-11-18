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

vim.api.nvim_create_user_command('CodeCompanionSelectChat', function()
  local contents = vim.tbl_map(
    function(bufnr) return string.format("[%s]", bufnr) end,
    _G.codecompanion_buffers
  )

  local opts = {
    actions = {
      ['enter'] = fzf.actions.buf_edit_or_qf,
      ['alt-s'] = fzf.actions.buf_split,
      ['alt-v'] = fzf.actions.buf_vsplit,
      ['alt-t'] = fzf.actions.buf_tabedit,
    },
    opts = {
      _fmt = {
        to = nil,
        from = function(entry, _)
          -- restore the format to something that `path.entry_to_file` can handle
          print("HELLO")
          local nbsp = require("fzf-lua").utils.nbsp
          -- local bufnr, lnum, text = s:match("%[(%d+)%].-(%d+) (.+)$")
          local bufnr = entry:match("%[(%d+)%]$")
          print(bufnr)
          if not bufnr then return "" end
          return string.format("[%s]%s", bufnr, utils.nbsp)
        end
      }
    },
  }

  fzf.fzf_exec(contents, opts)
end, {})
