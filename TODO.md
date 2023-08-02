- nix:
  - [ ] start using `nix` directly instead of `nix-env` and `nix-store`
  - [ ] add nix config to avoid long feature flags
  - [ ] investigate if there is a way to delete old nix-channel user-environment to perform a full `nix-store --gc`
- shell
  - [ ] write more notes on ZSH completion mechanisms
  - [ ] write your own starship config (check all presets and adapt)

- environment & install script:
  - [ ] Create an install and uninstall scripts inside nix which could use `stow` to manage the links to environment folder (those scripts can take parameters for system (linux or other), home directory name etc.)
  - [ ] in the script check if nerd fonts is installed otherwise overwrite starship toml with preset no-nerd-fonts
  - [ ] have an option to install alacritty-packages or not (cf. installation on a remote machine or not)
  - [ ] adapt the code for it to work on Mac OS

- misc:
  - [ ] tmux variables show as environment variables, see if this can be prevented
  - other tools to install ?
  - why do I have nix twice in the path in tmux ?
    - [ ] ripgrep + alias in zsh
    - [ ] jq

- tmux :
  - [x] update default command to use `zsh` (use relative path to .nix-profile/bin/zsh on purpose so it resolves to nix one when necessary - or even better use `which zsh` or something mettre un fallback sur bash si on trouve pas zsh)
  - [x] easier nvim / tmux pane change :
    - [x] open Github issue for neovim bug
    - [x] add hook pane-focus to set vim-mode on if vim is running
    - [x] install neovim with nix (unwrapped version, wrapped neovim allows to bake in some prebuilt plugins and generate special settings like upgrading the rtp in the `~/init.vim`, it also generates a wrapping shell script)
    - [x] better error messages and error handling with pcall and error in lua -> no need of pcall
    - [x] prettify your `nvim-tmux` plugin, check other plugins
      - [x] check if module already loaded -> irrelevant
      - [x] try to create a class to tmux.command.run() -> heavy, recreating objects all the time, won't do
      - [x] split in multiple files and put in `./nvim-tmux/init.lua`, etc.
    - [x] check if you can use command instead of callback to simplify autocmd
  - [x] make <Ctrl-v> and <v> behave like in vim in copy mode
  - [ ] make status bar pretty
  - [ ] look if tmux pkg manager: https://github.com/tmux-plugins/tpm makes sense ?
  - [ ] tmux sensible package -> check but copy paste if anything is interesting
  - [ ] change style of pane when in vim mode to indicate it is locked -> not sure this is really worth it since you will be able to get out of a vim locked window most of the time except when running nvim with your config remotely (experiment with setting vim-mode option as a pane option instead of window option)
  - [ ] Add `./tat.sh` script with nix allows to create a session named with the `pwd` automatically
  - [ ] look into tmuxinator or tmuxp to script session creation
  ```sh
#!/bin/sh
#
# Attach or create tmux session named the same as current directory.

  session_name="$(basename "$PWD" | tr . -)"

  session_exists() {
    tmux list-sessions | sed -E 's/:.*$//' | grep -q "^$session_name$"
  }

  not_in_tmux() {
    [ -z "$TMUX" ]
  }

  if not_in_tmux; then
    tmux new-session -As "$session_name"
  else
    if ! session_exists; then
      (TMUX='' tmux new-session -Ad -s "$session_name")
    fi
    tmux switch-client -t "$session_name"
  fi
  ```

- Neovim plugin in nix:
  - [x] write a function for plugins which:
    - [x] takes dependencies (use buildenv to merge plugins ?), so you bind some together
    - [x] generates doc tags if `doc/` present but `doc/tags` isn't, or `cp README.md  doc/` and generate doc tags if `doc/` does not exist but `README.md` exists (get inspiration from vimplugin nix code
  - [ ] update shas and rev tags more easily:
    - [ ] look into nix flakes: https://www.tweag.io/blog/2020-05-25-flakes/ so we don't have to manually update shas all the time
    - [ ] get inspiration from `editors/vim/plugins/generated.nix` or from treesitter generated grammars (cf. json file) to update plugins

- Neovim general config (lua code):
  - [ ] libuv:
    - [ ] look into libuv
    - [ ] check if it wouldn't be better to use `vim.loop` instead of `os.execute` to launch synchronous and asynchronous processes (inspiration from `fs.lua`)
    - [ ] if good update tmux plugin to use to use `vim.loop` instead of using `os.execute`
  - [ ] compare how you deal with plugins with lazy.lua and check that:
    - you can require them
    - the doc is there for each of them
    - you can upgrade them somewhat easily
    - double check lazy feature and make sure you don't miss anything (but the lazy loading, caching of module should be enabled already)
  - [ ] make an alias to start neovim with a folder (+ set cd to the targeted folder)
  - [ ] logging lib:
    - [ ] error message grab the name of the current file programmatically, so we know where the error is coming from
  - [ ] Once 0.10 is out, check out `readelf -d $(readlink -f $(which nvim))` and check if lpeg is now included in `Shared_libraries` (not in `RUNPATH`) or `RUNPATH`. It appeared when using the nightly source code built with the 9.1 code we get this:
    - for nvim 9.1
        ```
        $ readelf -d ./nvim
        Dynamic section at offset 0x442e60 contains 40 entries:
          Tag        Type                         Name/Value
         0x0000000000000001 (NEEDED)             Shared library: [libluv.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libtermkey.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libvterm.so.0]
         0x0000000000000001 (NEEDED)             Shared library: [libmsgpack-c.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [libtree-sitter.so.0]
         0x0000000000000001 (NEEDED)             Shared library: [libunibilium.so.4]
         0x0000000000000001 (NEEDED)             Shared library: [libluajit-5.1.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
         0x0000000000000001 (NEEDED)             Shared library: [libutil.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libuv.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [librt.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
         0x000000000000001d (RUNPATH)            Library runpath: [/nix/store/xdzfi8nkxpvcv6659gclqw4vjwvqxa66-libtermkey-0.22/lib:/nix/store/c70parvipldqrfip3cmdq6xdxrpk2scd-libuv-1.46.0/lib:/nix/store/8c4mr713pf09xql0clrbg8nc61vxwfcj-libvterm-neovim-0.3.2/lib:/nix/store/pfrayy46grjqavyqilsjw7xg8cvmkwyw-libluv-1.44.2-1/lib:/nix/store/gnd9h9dzhqjsks0vd7pmsinc9xzsgii6-msgpack-c-6.0.0/lib:/nix/store/sxcwjz5ad54i1h2hnfx47ymig76sz81d-luajit-2.1.0-2022-10-04-env/lib:/nix/store/fb2ayr725cqjz4my1zma93678mbdpxmi-tree-sitter-0.20.8/lib:/nix/store/3mmh0lv1ynwx8jw4v2lhv28ifdgwcfrb-unibilium-2.1.1/lib:/nix/store/1x4ijm9r1a88qk7zcmbbfza324gx1aac-glibc-2.37-8/lib]
        ```
    - for nvim 0.10-dev (nightly)
        ```
        $ readelf -d ./nvim
        Dynamic section at offset 0x505e40 contains 41 entries:
          Tag        Type                         Name/Value
         0x0000000000000001 (NEEDED)             Shared library: [libluv.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libtermkey.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libvterm.so.0]
         0x0000000000000001 (NEEDED)             Shared library: [libmsgpack-c.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [libtree-sitter.so.0]
         0x0000000000000001 (NEEDED)             Shared library: [libunibilium.so.4]
         0x0000000000000001 (NEEDED)             Shared library: [/nix/store/sxcwjz5ad54i1h2hnfx47ymig76sz81d-luajit-2.1.0-2022-10-04-env/lib/lua/5.1/lpeg.so]
         0x0000000000000001 (NEEDED)             Shared library: [libluajit-5.1.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
         0x0000000000000001 (NEEDED)             Shared library: [libutil.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libuv.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libdl.so.2]
         0x0000000000000001 (NEEDED)             Shared library: [librt.so.1]
         0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
         0x000000000000001d (RUNPATH)            Library runpath: [/nix/store/xdzfi8nkxpvcv6659gclqw4vjwvqxa66-libtermkey-0.22/lib:/nix/store/c70parvipldqrfip3cmdq6xdxrpk2scd-libuv-1.46.0/lib:/nix/store/8c4mr713pf09xql0clrbg8nc61vxwfcj-libvterm-neovim-0.3.2/lib:/nix/store/pfrayy46grjqavyqilsjw7xg8cvmkwyw-libluv-1.44.2-1/lib:/nix/store/gnd9h9dzhqjsks0vd7pmsinc9xzsgii6-msgpack-c-6.0.0/lib:/nix/store/sxcwjz5ad54i1h2hnfx47ymig76sz81d-luajit-2.1.0-2022-10-04-env/lib:/nix/store/fb2ayr725cqjz4my1zma93678mbdpxmi-tree-sitter-0.20.8/lib:/nix/store/3mmh0lv1ynwx8jw4v2lhv28ifdgwcfrb-unibilium-2.1.1/lib:/nix/store/1x4ijm9r1a88qk7zcmbbfza324gx1aac-glibc-2.37-8/lib]
            ```

- Neovim plugins:
  - [ ] Pretty status line: nvim-lualine/lualine.nvim:
    - [x] Install
    - [ ] Configure
  - [x] nvim-treesitter/nvim-treesitter
    - [x] understand tree-sitter concepts
    - [x] understand syntax, indentation, folding (just check the :help)
    - [x] understand how the plugin works
    - [x] Install plugin
    - [x] Configure
    - [x] add parsers for markdown, scala, rust, go, nix, haskell and OCaml
  - [ ] Neotree explorer:
    - [x] install
    - [ ] configure
  - [x] comments: https://github.com/numToStr/Comment.nvim
    - [x] install
    - [x] configure
  - [x] parenthesis surrounding: https://github.com/kylechui/nvim-surround
    - [x] install
    - [x] configure
  - [ ] Fuzzy finder
    - [ ] nvim-telescope/telescope.nvim
    - [ ] nvim-telescope/telescope-fzf-native.nvim -> look if really necessary
  - [ ] nvim-in-tmux:
     - see if you want to rework the module, see if you want to set the mappings outside in all cases
  - [ ] Theme
    - [ ] option 1: navarasu/onedark.nvim (inspired by Atom)
    - [ ] option 2: https://github.com/norcalli/nvim-colorizer.lua
    - [ ] others 3: https://github.com/folke/tokyonight.nvim
  - [ ] Git (let's move away from fugitive, we aim for lua only plugins):
    - use neogit
    - use diffview
    - if not enough, external tool lazygit: requires custom keybindings definition https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  - [ ] LSP:
    - [ ] understand lsp
    - [ ] use nix to install lsp servers
    - [ ] neovim/nvim-lspconfig
  - [ ] completion
    - hrsh7th/nvim-cmp
    - check dependencies:
      - snippet engine (L3MON4D3/LuaSnip, check others ?)
      - lsp completion hrsh7th/cmp-nvim-lsp
    - cmp sources plugins:
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path"
    - predefined snippet templates:
      - https://github.com/rafamadriz/friendly-snippets/wiki

- Neovim plugins nice to have:

  - [ ] alternatives to vimux or vim-tmux-runner, idea write your plugin to send text to other tmux pane. Implementation sketch :
    - use external script so you can do the same from outside nvim
    - send a particular register to the tty of a particular pane
    - send the content of a predefined register (in normal mode) to the left/right/up/down (C-x C-l, C-x C-k, etc.)
    - C-x C-x resends to the same pane
  - [ ] implement zoom feature, get inspiration from https://github.com/dhruvasagar/vim-zoom
  - [ ] windwp/nvim-autopairs
  - [ ] show blanks https://github.com/lukas-reineke/indent-blankline.nvim
  - [ ] folke/which-key.nvim
  - [ ] neodev (plugin for lua in neovim, help + autocompletion, etc., see if still necessary after cmp-nvim-lua)
