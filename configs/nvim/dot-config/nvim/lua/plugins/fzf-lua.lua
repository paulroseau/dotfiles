local fzf = require("fzf-lua")

-- Adapted from fzf-lua.actions to prevent blocking deletions of dirty
-- buffers
local buf_del = function(selected, opts)
  for _, sel in ipairs(selected) do
    local entry = fzf.path.entry_to_file(sel, opts)
    if entry.bufnr then
      vim.api.nvim_buf_delete(entry.bufnr, { force = true })
    end
  end
end

fzf.setup({
  keymap = {
    -- These override the default tables completely so we need to include
    -- everything we need, including what we don't want to modify
    builtin = {
      ["<M-p>"] = "toggle-preview",
      ["<M-r>"] = "toggle-preview-cw",
      ["<M-w>"] = "toggle-preview-wrap",
      ["<M-e>"] = "preview-page-up",
      ["<M-d>"] = "preview-page-down",
    },
    fzf = {
      ["ctrl-z"] = "abort",
      ["ctrl-u"] = "unix-line-discard",
      ["ctrl-a"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      ["alt-p"] = "toggle-preview",
      ["alt-w"] = "toggle-preview-wrap",
      ["alt-e"] = "preview-page-up",
      ["alt-d"] = "preview-page-down",
    },
  },
  actions = {
    -- These are the default actions inherited by other pickeres, such as git_files, buffers, etc.
    -- Here we are overriding the plugin defaults for these default actions
    -- More details with :help fzf-lua-default-options
    files = {
      ["enter"] = fzf.actions.file_edit_or_qf,
      ["alt-s"] = fzf.actions.file_split,
      ["alt-v"] = fzf.actions.file_vsplit,
      ["alt-t"] = fzf.actions.file_tabedit,
      ["alt-q"] = fzf.actions.file_sel_to_qf,
      ["alt-l"] = fzf.actions.file_sel_to_ll,
    },
  },
  buffers = {
    actions = {
      ["ctrl-x"] = { fn = buf_del, reload = true },
    }
  },
  tabs = {
    actions = {
      ["ctrl-x"] = { fn = buf_del, reload = true },
    }
  },
  helptags = {
    actions = {
      ["alt-s"] = fzf.actions.help,
      ["alt-v"] = fzf.actions.help_vert,
      ["alt-t"] = fzf.actions.help_tab,
    },
  },
  keymaps = {
    actions = {
      ["alt-s"] = fzf.actions.keymap_split,
      ["alt-v"] = fzf.actions.keymap_vsplit,
      ["alt-t"] = fzf.actions.keymap_tabedit,
    },
  },
  diagnostics = {
    copen = function()
      vim.cmd("copen")
      vim.cmd(".cc")
    end,
  },
  git = {
    bcommits = {
      actions = {
        ["alt-s"] = fzf.actions.git_buf_split,
        ["alt-v"] = fzf.actions.git_buf_vsplit,
        ["alt-t"] = fzf.actions.git_buf_tabedit,
      },
    },
  },
  manpages = {
    actions = {
      ["alt-s"] = fzf.actions.man,
      ["alt-v"] = fzf.actions.man_vert,
      ["alt-t"] = fzf.actions.man_tab,
    },
  }
})

local function wrap_vertical(fn)
  local vertial_layout_opts = {
    winopts = {
      preview = {
        layout = "vertical"
      }
    }
  }
  return function()
    fn(vertial_layout_opts)
  end
end

-- Mappings
vim.keymap.set({ '' }, '<leader>z', fzf.builtin)

vim.keymap.set({ 'n' }, '<leader>f', fzf.files)
vim.keymap.set({ 'n' }, '<leader>b', fzf.buffers)
vim.keymap.set({ 'n' }, '<leader>h', fzf.help_tags)
vim.keymap.set({ '', 'i' }, '<leader>p', fzf.registers)

vim.keymap.set({ 'n' }, '<leader>L', fzf.grep_project)
vim.keymap.set({ 'n' }, '<leader>l', fzf.blines)
vim.keymap.set({ 'n' }, '<leader>*', fzf.grep_cword)
vim.keymap.set({ 'v' }, '<leader>*', fzf.grep_visual)

vim.keymap.set({ 'n' }, '<leader>r', fzf.lsp_references)
vim.keymap.set({ 'n' }, '<leader>a', wrap_vertical(fzf.lsp_code_actions))
vim.keymap.set({ 'n' }, '<leader>S', fzf.lsp_live_workspace_symbols)
vim.keymap.set({ 'n' }, '<leader>s', fzf.lsp_document_symbols)
vim.keymap.set({ 'n' }, '<leader>D', wrap_vertical(fzf.lsp_workspace_diagnostics))
vim.keymap.set({ 'n' }, '<leader>d', wrap_vertical(fzf.lsp_document_diagnostics))
