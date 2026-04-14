local M = {}

function M.cmd_then_terminal(split_cmd)
  return function()
    vim.cmd(split_cmd)
    vim.cmd('terminal')
  end
end

function M.toogle_boolean_option(option_name)
  return function()
    vim.o[option_name] = not vim.o[option_name]
  end
end

function M.visual_selection_search(search_character)
  return function()
    local previous_s_register = vim.fn.getreg('s')
    vim.cmd('normal! "sy')
    local search_pattern = vim.fn.escape(vim.fn.getreg('s'), '\\' .. search_character)
    search_pattern = vim.fn.substitute(search_pattern, '\n', '\\\\n', 'g')
    vim.fn.setreg('s', previous_s_register)
    vim.cmd('silent! ' .. search_character .. '\\V' .. search_pattern)
  end
end

function M.clear_trailing_whitespaces()
  local pos = vim.fn.getpos('.')
  -- need silent! for when the pattern is not found
  -- (keymap { silent = true } option is equivalent to silent not silent!, ie. errors will be echoed)
  vim.cmd([[silent! %substitute/[ \t]\+$//]])
  vim.cmd('nohlsearch')
  vim.fn.setpos('.', pos)
end

function M.locationlist_or_quickfixlist(action)
  return function()
    local locations = vim.fn.getloclist(0)
    if not vim.tbl_isempty(locations) then
      vim.cmd('silent! l' .. action)
    else
      vim.cmd('silent! c' .. action)
    end
  end
end

-- For when no LSP client is attached or no attached client supports renaming
function M.rename_with_substitute()
  local cword = vim.fn.expand('<cword>')
  local prompt_opts = {
    prompt = 'New Name: ',
    default = cword,
  }

  vim.ui.input(prompt_opts, function(input)
    if not input or #input == 0 then
      return
    end
    local pos = vim.fn.getpos('.')
    local substitute_cmd = string.format('%%substitute/\\<%s\\>/%s/eg', cword, input)
    vim.cmd(substitute_cmd)
    vim.cmd('nohlsearch')
    vim.fn.setpos('.', pos)
  end)
end

return M
