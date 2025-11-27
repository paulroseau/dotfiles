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

local function select_chat()
  local contents = vim.tbl_map(
    function(bufnr) return string.format("[%s]", bufnr) end,
    _G.codecompanion_buffers
  )

  for idx, metadata in pairs(_G.codecompanion_chat_metadata) do
    vim.print(idx)
    vim.print(metadata)
  end

  local opts = {
    actions = {
      ['enter'] = fzf.actions.buf_edit_or_qf,
      ['alt-s'] = fzf.actions.buf_split,
      ['alt-v'] = fzf.actions.buf_vsplit,
      ['alt-t'] = fzf.actions.buf_tabedit,
    },
    _fmt = {
      to = nil,
      from = function(entry, _)
        -- restore the format to something that `path.entry_to_file` can handle
        local nbsp = require("fzf-lua").utils.nbsp
        -- local bufnr, lnum, text = s:match("%[(%d+)%].-(%d+) (.+)$")
        local bufnr = entry:match("%[(%d+)%]$")
        print(bufnr)
        if not bufnr then return "" end
        return string.format("[%s]%s", bufnr, nbsp)
      end
    },
  }

  return fzf.fzf_exec(contents, opts)
end

vim.api.nvim_create_user_command('CodeCompanionSelectChat', select_chat, {})

vim.keymap.set({ 'n' }, '<leader>C', select_chat)
