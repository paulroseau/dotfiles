local M = {}

local pattern = 'term://*'

function M.create(term_group)
  vim.api.nvim_create_autocmd('TermOpen', {
    group = term_group,
    callback = function(_)
      vim.cmd('startinsert')
    end,
  })

  vim.api.nvim_create_autocmd('TermClose', {
    group = term_group,
    callback = function(args)
      -- small defer so Neovim finishes cleaning up the terminal
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = term_group,
    pattern = pattern,
    callback = function(args)
      local saved_mode = vim.b[args.buf].term_mode
      if saved_mode == 't' or saved_mode == 'i' then
        vim.cmd('startinsert')
      end
      -- If saved_mode was 'n' (normal mode) or nil (first time), stay in normal mode
    end,
  })

  vim.api.nvim_create_autocmd('BufLeave', {
    group = term_group,
    pattern = pattern,
    callback = function(args)
      local mode = vim.api.nvim_get_mode().mode
      vim.b[args.buf].term_mode = mode
    end,
  })
end

return M
