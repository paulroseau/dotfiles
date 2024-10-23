- nix:
  - [/] start using `nix` directly instead of `nix-env` and `nix-store`
    => part of nix flake, we decided not to use them
  - [x] add nix config to avoid long feature flags
  - [/] investigate if there is a way to delete old nix-channel user-environment to perform a full `nix-store --gc`
    => not sure what I meant here, but to remove old environments as well as a gc, just use `nix-collect-garbage --delete-old`

- shell
  - [/] write more notes on ZSH completion mechanisms
  - [x] find a nice Pager to read man page (`bat` could do, check out `most`), and set the `PAGER` env variable in your .zshrc
  - [ ] write your own starship config (check all presets and adapt)
  - [ ] generate separate zsh script to source each derivation zsh extensions (plugins + kubectl, etc.) so that you refer to one script only when sourcing from .zshrc

- environment & install script:
  - [ ] Create an install and uninstall scripts inside nix which could use `stow` to manage the links to environment folder (those scripts can take parameters for system (linux or other), home directory name etc.)
  - [ ] in the script check if nerd fonts is installed otherwise overwrite starship toml with preset no-nerd-fonts
  - [ ] have an option to install alacritty-packages or not (cf. installation on a remote machine or not)
  - [ ] adapt the code for it to work on Mac OS

- misc:
  - [ ] tmux variables show as environment variables, see if this can be prevented
  - [ ] why do I have nix-profile one more time in zsh, and 2 more times in tmux in the path ?

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
  - [ ] make status bar pretty:
    - https://tao-of-tmux.readthedocs.io/en/latest/manuscript/09-status-bar.html
    (read the whole blog)
    - https://medium.com/hackernoon/customizing-tmux-b3d2a5050207
  - [ ] look if [tmux pkg manager](https://github.com/tmux-plugins/tpm) makes sense ?
  - [ ] tmux sensible package -> check but copy paste if anything is interesting
  - [ ] change style of pane when in vim mode to indicate it is locked -> not sure this is really worth it since you will be able to get out of a vim locked window most of the time except when running nvim with your config remotely (experiment with setting vim-mode option as a pane option instead of window option)
  - [ ] Add `./tat.sh` script with nix allows to create a session named with the `pwd` automatically
  - [ ] look into Teamocil, tmuxinator or tmuxp to script session creation (tmuxp is written by the guy from tao-of-tmux, it is in python)
  ```bash
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
  - [x] update shas and rev tags more easily:
    - [x] look into nix flakes: https://www.tweag.io/blog/2020-05-25-flakes/ so we don't have to manually update shas all the time -> won't do cf. your notes in nix about flakes
    - [-] get inspiration from `editors/vim/plugins/generated.nix` or from treesitter generated grammars (cf. json file) to update plugins
    - [x] use niv to handle plugins source versions

- Neovim general config (lua code):
  - [ ] libuv:
    - [ ] look into libuv
    - [ ] check if it wouldn't be better to use `vim.loop` instead of `os.execute` to launch synchronous and asynchronous processes (inspiration from `fs.lua`)
    - [ ] if good update tmux plugin to use `vim.loop` instead of using `os.execute`
  - [ ] compare how you deal with plugins with lazy.lua and check that:
    - you can require them
    - the doc is there for each of them
    - you can upgrade them somewhat easily
    - double check lazy feature and make sure you don't miss anything (but the lazy loading, caching of module should be enabled already)
  - [ ] make an alias to start neovim with a folder (+ set cd to the targeted folder)
  - [ ] logging lib:
    - [ ] error message grab the name of the current file programmatically, so we know where the error is coming from:
      - check if "require(plenary.log)" does the trick
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
  - [ ] nvim-treesitter/nvim-treesitter
    - [x] understand tree-sitter concepts
    - [x] understand syntax, indentation, folding (just check the :help)
    - [x] understand how the plugin works
    - [x] Install plugin
    - [x] Configure
    - [x] add parsers for markdown, scala, rust, go, nix, haskell and OCaml
    - [x] fix bash and scala queries, you might need to upgrade bash and scala treesitter to a working version or allow to patch some queries file in the nvim-treesitter
    - [ ] allow to disable treesitter on one buffer (if it blows up it is impossible to work) -> checkout builtin TSDisable
    - [ ] the plugin sets foldmethod expr globally, if we don't have a parser installed and we want to fold, we need to reset the foldmethod
  - [ ] Neotree explorer:
    - [x] install
    - [x] update to have the links showing
    - [ ] toggle symlink + info display on/off
    - [ ] configure:
      - [x] open node recursively: cf. https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipies#emulating-vims-fold-commands
      - [ ] change behaviour of `X` so that it closes all subnodes but keep current node open
      - [ ] replicate NerdTree navigation :
        - [ ] P: go to root
        - [ ] p: go to parent (this is pasting at the moment)
        - [ ] K: go to first child
        - [ ] J: go to last child
        - [ ] <C-j>: go to next sibling
        - [ ] <C-k>: go to prev sibling
      - [ ] add `dd` to delete a file without confirmation
      - [ ] see if you can rework confirmation box to avoid typing <CR>
  - [x] comments: https://github.com/numToStr/Comment.nvim
    - [x] install
    - [x] configure
    - [ ] checkout JoosepAlviste/nvim-ts-context-commentstring which could be interesting to comment nested stuff (code instide of markdown, js inside of html, etc.)
  - [x] parenthesis surrounding: https://github.com/kylechui/nvim-surround
    - [x] install
    - [x] configure
  - [ ] nvim-in-tmux:
     - [x] move it inside `./plugins`, rework the module like nvim-treesitter
     - [x] set the mappings outside
     - [ ] check if you want to use vim.loop (libuv) instead of `os.execute`
  - [ ] Use fzf-lua.vim instead of Telescope:
    - [x] understand what you can do with fzf from: https://www.youtube.com/watch?v=qgG5Jhi_Els
    - [x] review if you can remove zsh directory plugin
    - [x] install fzf-lua.vim & remove Telescope
    - [x] rename all `.config` files in here with `dot-` and use `stow --dotfiles` in the install script
      - [ ] not working for alacritty with dot-config cf. https://github.com/aspiers/stow/issues/33
      - [ ] exercise: write your own `stow` equivalent in Rust?
    - [x] understand the philosophy of this plugin a bit:
      - [x] read README.md
      - [x] check core.fzf_exec
      - [x] take some notes
    - [ ] make notes on FFI and luaJIT + loadlib (how to dynamically load a library into Lua - from your telescope endeavor)
      - https://www.lua.org/pil/contents.html#P4
      - https://luajit.org/ext_ffi.html
      - https://www.lua.org/pil/contents.html
  - [x] Check youtube series on Lunar Nvim (distro): https://www.youtube.com/playlist?list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ
  - [x] Theme
    - [x] option 1: https://github.com/navarasu/onedark.nvim (inspired by Atom)
    - [-] option 2: https://github.com/norcalli/nvim-colorizer.lua
    - [x] others 3: https://github.com/folke/tokyonight.nvim
  - [/] Bufferline
    - it is good but does way too much compared to what you need. All you need
    is a nice name for tabs (or maybe just a number), and a floating window appearing on the side to show
    the list of buffers when typing <C-j> and <C-k>, but fzf does this aleady pretty well
  - [x] install https://github.com/willothy/flatten.nvim to allow to launch nvim inside a terminal (in particular for git rebase -i)
  - [ ] Git:
    - Various options to consider:
      - [x] good old Fugitive.vim:
        - [x] add `,g` mappings for `:Git<CR>`
        - downside it is in vimL
      - [ ] checkout GitSigns, looks cool, you can stage what you changed, but no sure it as good as the Gvdiff of TreeSitter, look around
      - [ ] explore: neogit + diffview
      - [x] `lazygit` (external tool): requires custom keybindings definition https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
        -> powerful but a bit too much actually, rather stick to something more barebone
  - [ ] Nice tab title
      - [ ] https://github.com/alvarosevilla95/luatab.nvim/tree/master for nicer tabs, fork the repo since there is some Telescope specific shit and the plugin is a few lines long
  - [x] LSP:
    - [x] understand lsp
    - [x] use nix to install lsp servers
    - [x] neovim/nvim-lspconfig
  - [x] completion
    - hrsh7th/nvim-cmp
    - check dependencies:
      - snippet engine (L3MON4D3/LuaSnip, check others ?)
      - lsp completion hrsh7th/cmp-nvim-lsp
    - cmp sources plugins:
      - "saadparwaiz1/cmp_luasnip",
      - "hrsh7th/cmp-nvim-lua",
      - "hrsh7th/cmp-nvim-lsp",
      - "hrsh7th/cmp-buffer",
      - "hrsh7th/cmp-path"
    - predefined snippet templates:
      - https://github.com/rafamadriz/friendly-snippets/wiki

- Install bash-language-server (not part of nixpgks, it is a typescript application)

- Neovim plugins nice to have:
  - [x] Add mapping to scroll preview window in fzf-lua
  - [ ] https://github.com/alvarosevilla95/luatab.nvim/tree/master for nicer tabs, fork the repo since there is some Telescope specific shit and the plugin is a few lines long
  - [ ] nvim/dap debugger
  - [/] find or write a plugin that would display a floating window with the list of buffers as you cycle through them with <C-j>, <C-k> so you know what is coming next, but honestly fzf with buffers is pretty good for that already, see if you want to use https://github.com/stevearc/dressing.nvim for that -> see if you cannot just update fzf buffers so that it displays the list without the first buffer on top
  - [ ] check https://github.com/rcarriga/nvim-notify for nicer notifications (in pop up windows)
  - [x] Install L3MON4D3/LuaSnip + nvim-cmp binding
  - [x] https://github.com/hrsh7th/cmp-cmdline see if interesting (completion after `:` and `/`)
  - [ ] checkout lsp-signature-help nvim cmp source (already installed) you might want to configure it
  - [ ] could be good to restrict Fzf ripgrep lines to just one type of files
  - [ ] adjust the nvim lua cmp plugin so it can autocomplete in cmd line even when not editing a vim or lua file (right now available uses the filetype)
  - [/] source a lua file (usage example: change the colorscheme option of onedark without needing to quit neovim and restart)
    -> use :luafile
  - [ ] find a multiselect plugin so when you can search and replace without having to do * and the :s//blalba/, but direclty get the cursor everywhere
  - [ ] make your own script to increase and diminish foldlevel locally on the fold you are on. Strategy :
       1. select the containing fold of the cursor (invisibly or something)
       2. if you want to open, just execute foldopen on the range
       3. if you want to close, find the lines with the highest foldlevel in the range and run foldclose on those
  - [ ] alternatives to vimux or vim-tmux-runner, idea write your plugin to send text to other tmux pane. Implementation sketch :
    - use external script so you can do the same from outside nvim
    - send a particular register to the tty of a particular pane
    - send the content of a predefined register (in normal mode) to the left/right/up/down (C-x C-l, C-x C-k, etc.)
    - C-x C-x resends to the same pane
    Edit: checkout toggleterm before
  - [ ] set textwidth to 0 for ft=markdown
  - [ ] implement zoom feature, get inspiration from https://github.com/dhruvasagar/vim-zoom
  - [ ] windwp/nvim-autopairs:
    - not sure if we want to install it, I am not a fan of autopairing (we could have it setup for certain filetype - programming languages)
    - it hooks into cmp so when you press <CR> for a function it adds the ()
    automatically, which could be cool
  - [ ] show blanks https://github.com/lukas-reineke/indent-blankline.nvim
  - [ ] folke/which-key.nvim
  - [ ] JoosepAlviste/nvim-ts-context-commentstring:
    - could be interesting to comment nested stuff (code instide of markdown, js inside of html, etc.)
  - [ ] neodev (plugin for lua in neovim, help + autocompletion, etc., see if still necessary after cmp-nvim-lua)
  - [ ] install some extra colorschemes from https://github.com/rockerBOO/awesome-neovim#colorscheme (kanagawa, nord)
  - [ ] Allow to delete files from fzf-lua with `Ctrl-x` or `Ctrl-d` just like we do for buffers

- exercises/projects
  - write your own `stow` equivalent in Rust?
  - refactor fugitive in Lua

- Books:
  - Learning eBPF by Liz Rice: https://github.com/lizrice/learning-ebpf 

- Misc:
  - think about finding a nice filewatcher to recomplie stuff when file changes for example (`entr` is recommended by the guy from the tao-of-tmux)

- Fixes:
  - lualine hijacks intro screen, cf. https://github.com/nvim-lualine/lualine.nvim/issues/259
  - add description to each of your mappings so Telescope mapping helps you better (some show anonymous function)

- sources:
  - think about checking out neovim awesome for plugins

- Bugs:
  - neovim:
    - Terminal Mode gets deactivated when moving in/out of the Terminal window: https://github.com/neovim/neovim/issues/26881
    However toggleterm deals with this just fine, checkout how `persist_mode` works in toggleterm
