local fzf = require("fzf-lua")

fzf.setup({
  keymap = {
    builtin = {
      ["<C-r>"] = "toggle-preview-cw",
      ["<C-p>"] = "toggle-preview",
      ["<C-w>"] = "toggle-preview-wrap",
      ["<M-e>"] = "preview-page-up",
      ["<M-d>"] = "preview-page-down",
    },
    fzf = {
      ["ctrl-p"] = "toggle-preview",
      ["ctrl-w"] = "toggle-preview-wrap",
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
  manpages = {
    actions = {
      ["alt-s"] = fzf.actions.man,
      ["alt-v"] = fzf.actions.man_vert,
      ["alt-t"] = fzf.actions.man_tab,
    },
  }
})

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
