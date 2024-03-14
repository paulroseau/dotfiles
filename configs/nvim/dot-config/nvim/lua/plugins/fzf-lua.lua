local fzf = require("fzf-lua")

fzf.setup({
  keymap = {
    -- These override the default tables completely so we need to include all we
    -- need, including what we don't want to modify
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
    -- These override the default tables completely
    -- so we need to include all the orignal entries
    -- cf. :help fzf-lua-default-options
    files = {
      ["default"] = fzf.actions.file_edit_or_qf,
      ["alt-s"]   = fzf.actions.file_split,
      ["alt-v"]   = fzf.actions.file_vsplit,
      ["alt-t"]   = fzf.actions.file_tabedit,
      ["alt-q"]   = fzf.actions.file_sel_to_qf,
      ["alt-l"]   = fzf.actions.file_sel_to_ll,
    },
    buffers = {
      ["default"] = fzf.actions.buf_edit,
      ["alt-s"]   = fzf.actions.buf_split,
      ["alt-v"]   = fzf.actions.buf_vsplit,
      ["alt-t"]   = fzf.actions.buf_tabedit,
    }
  },
  buffers = {
    actions = {
      ["ctrl-x"] = {
        fn = function(selected, opts)
          return fzf.actions.vimcmd_buf("bw!", selected, opts)
        end,
        reload = true
      }
    },
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
  diagnostics ={
    copen = function () 
      vim.cmd("copen")
      vim.cmd(".cc")
    end,
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
vim.keymap.set({ 'n' }, '<leader>z', fzf.builtin)

vim.keymap.set({ 'n' }, '<leader>f', fzf.files)
vim.keymap.set({ 'n' }, '<C-j>', fzf.buffers)
vim.keymap.set({ 'n' }, '<leader>h', fzf.help_tags)
vim.keymap.set({ '', 'i' }, '<leader>p', fzf.registers)

vim.keymap.set({ 'n' }, '<leader>l', fzf.blines)
vim.keymap.set({ 'n' }, '<leader>L', fzf.grep_project)
vim.keymap.set({ 'n' }, '<leader>g', fzf.grep_cword)
vim.keymap.set({ 'v' }, '<leader>g', fzf.grep_visual)
vim.keymap.set({ 'n' }, '<leader>G', fzf.grep_cWORD)

vim.keymap.set({ 'n' }, '<C-\\>', fzf.lsp_references)
vim.keymap.set({ 'n' }, '<leader>a', wrap_vertical(fzf.lsp_code_actions))
vim.keymap.set({ 'n' }, '<leader>s', fzf.lsp_document_symbols)
vim.keymap.set({ 'n' }, '<leader>S', fzf.lsp_workspace_symbols)
vim.keymap.set({ 'n' }, '<leader>d', wrap_vertical(fzf.lsp_document_diagnostics))
vim.keymap.set({ 'n' }, '<leader>D', wrap_vertical(fzf.lsp_workspace_diagnostics))
