- POC on Windows:
    - [x] install wezterm manually (zipfile) or winget?
    - [ ] copy your wezterm config
    - [x] install coder and configure cli
      ```
      winget install Coder.Coder
      coder login http://...
      coder config-ssh
      ssh coder.<...>
      ```
    - [ ] install wezterm on remote Linux image

- For the office (extra script, maybe in the office's gitlab):
  - [ ] install missing binaries (tmux, zsh, tig via conda?)
  - [ ] install uv with cargo
  - [ ] install pyright globally through uv

- [x] review install script
  - [x] manual install script
    - [x] pin versions of cargo installed binaries
    - [x] make get-plugins work in plain bash (source .env manually)
    - [x] install nvim doc when downloading nvim plugins
  - [x] replace fzf with skim
    - [x] install with nix
    - [x] install shell completions for skim in manual mode (git clone based on skim version, grab just the script and put them ~/.local/share/skim/)
    - [x] update fzf-lua
  - [x] install wezterm (mux in particular)
- [x] install fzf manually again (shell expansion) but keep skim in the manual install to allow switching between the 2
- [x] allow to install js based stuff
  - [x] install nvm (little dance probably with your store)
  - [x] install node version (set node version in env variable)
  - [x] check where npm list -g (maybe add that directly to the PATH) or have a wrapper around to npm to install + link (maybe cleaner)
- [x] remove lsp-config:
   - [x] find a way to customize lua-ls to include vim.env :help lsp-quickstart
     -> looks like you need to install lazydev...
   - [/] root_markers seem to be what lspconfig does "by hand" mostly 
     -> rust-analyzer config seems a bit complex, moved to rustaceanvim
   - [x] signature help
     -> automatically mapped to Ctrl-s in insert mode
   - [x] bindings to see types
     -> just use hover
- [x] install blink.cmp and trash out nvim-cmp
  - [x] update version to v1.3.1 so that you have a prebuilt binary to download at work
  - [x] have a default setting to rust/fall back lua
  - [x] config
  - [x] double check:
    - [x] toggle documentation with M-p, and scroll
    - [/] lsp signature
      -> nvim kinda does what we want by default, disable it
    - [x] lsp
    - [x] nvim lua plugin for files which are in `~/.config/nvim`
- [x] lsp:
  - [x] fix on_attach not working
- [x] lsp pyright:
  - [x] fix loading of on_attach
- [x] lsp rust:
  - [x] install rustaceanvim
  - [x] check auto-formatting
  - [x] check signature
  - [x] check hover
- [x] snippet: do you still need luasnip in 0.11+? -> No
  - [x] let's replace LuaSnip with the built-in 
  - [x] check what friednly snippets brought to you with blink.cmp and make sure snippet expansion works
- [x] remove all nvim-cmp stuff in nix
- [x] install mini-pairs or autopairs
- [x] nvim prettier tabs by using https://github.com/alvarosevilla95/luatab.nvim
- [x] install zen-mode
- [x] install todo-comment
  => tried it, removed it, obnoxious

# Neovim

- [ ] check plugins listed on lazyvim (in particular conform for formatting, dashboard)
  - [ ] for conform see if you need to install prettier, if so add it with nix (not in nixpkgs)
- [ ] rework your smart windows by separating configuration/initialization (ie. no setup(config)): https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#sleeping_bed-lazy-loading
- [ ] add luacats annotations in your config: https://luals.github.io/wiki/annotations (also for wezterm)
- [ ] review all dos and don'ts in https://github.com/nvim-neorocks/nvim-best-practices
- [ ] fix clangd
- [ ] check plugins listed on lazyvim (in particular conform for formatting, dashboard)
- [ ] check snacks:
    - [x] file explorer -> mouais, not convinced neo-tree is better
    - [x] same for picker, fzf-lua better
    - [ ] picker -> not a fan, but there is search projects, recent files, undo which are really nice
    - [ ] check how snacks implement toggling
    - [ ] rework mapping like snacks default

- NB: on hover and signature help, monitor this issue: https://github.com/neovim/neovim/issues/28140 which asks for the ability to toggle the preview window (links to this more general issue: https://github.com/neovim/neovim/issues/31206), right now you just map K to calling vim.lsp.buf.hover twice, but you would still need to press `q` to exit, ideally we just exit with `K` as well

# Yazi

- remap using <A-J/K> for changin windows and `J`/`K` for changing tabs cf. https://yazi-rs.github.io/docs/configuration/keymap and `(/)` for swapping tabs https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/keymap-default.toml

# Wezterm

- [x] Rabbit-hole #1: how does wezterm link to `lua.so` when built with nix? It looks like lua.so is looked up dynamically with pkg-config, so explore:
  - [ ] pkg-config
  - [ ] pkg-config on nix
  - [ ] wezterm building on nix
    => wezterm uses the vendored lua code, so pkg-config is irrelevant here

- [ ] Wezterm: prettier tabs and statusline: https://github.com/michaelbrusegard/tabline.wez (for status line print Nvim icon if nvim_mode is on but nvim_ignore is off)
  - [x] fix swapping on right side
  - [ ] set up tab rendering
  - [ ] test all existing components in the tab
  - [ ] make the map for all components programmatically launch require('tabline.components' .. name) (if it fails return nil), through a setmetatable({}, {__index = function(k, t)})
  - [ ] convert all old components
  - [ ] add nvim-mode component
- [ ] Consider using the Input select for switching workspaces (fonts? color_scheme? maybe OTT)
  - improve in lua object programming: https://www.lua.org/pil/contents.html#P2 (13. tables & 16. classes)
  -> checkout those to get inspiration, but you probably will define your own selector (not just for domains, workspaces, but also fonts etc.)
    - https://github.com/MLFlexer/smart_workspace_switcher.wezterm/blob/main/plugin/init.lua
    - https://github.com/DavidRR-F/quick_domains.wezterm
    - https://github.com/mikkasendke/sessionizer.wezterm (maybe the closest to your need)
  -> use the table trick to display clean values / make the selector its own lua module
  -> issue with for color_scheme (config_overrides) when creating new workspace it keeps the setting (looks like a bug)
- [ ] Create a domain dynamically ? needs to be added to wezterm -> no but prepare a config file to edit, test with docker container or VM
- [ ] If you ended up using external plugins with `wezterm.plugin.require()`, see how you can:
  - [ ] download the plugins with nix in the same vein as what are doing for neovim-plugins (through `niv`)
  - [ ] write a little utility to add each folder inside there to the lua path/cpath
- Wezterm missing:
  - Closing a workspace at once (not supported natively, lots of lua code cf. https://github.com/wezterm/wezterm/issues/3658, not worth it)
  - contribute to add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722

- Wezterm Big issues at the moment:
  - search not intuitive, selection by default also when you come back, case sensitivity, there should be only 1 copy mode
  - missing choose-tree, more uniform menus
      import pane/tab from elsewhere (need choose-tree)
  - missing focus pane events
  - export pane/tab to new workspace (1 window/workspace)
  - move pane/tab to new workspace (1 window/workspace)
  - customizable keymaps in menu mode and search mode (editing part, emacs style would be good by default)
  - better vim movements in Copy Mode (e not respected, E, etc.)

- Wezterm potential enhancement:
  - change layout like in nvim, right now you can just rotate panes
  - have a command line (vim style? C-a : and C-a /) with either emacs or vim mappings, but with keys still customizable

- Wezterm:
    - [ ] configure multiplexing session and check that clipboard is working fine
  - Karabiner:
    - [ ] check if conditions for karabiner could not be factored out
    - [x] find how to apply changes to when wezterm is launched from the command line -> use FilePath instead of bundle identifier
  - Default program:
    - [ ] (same issue on Alacritty) on MacOS the default PATH is prepended, so /bin/zsh is started instead of the nix one. Modifications to the path are not taken into account unless you launch it via command line (for which karabiner does not work ...)
      -> potential solution, wrap it in Nix
  - [ ] replicate your tmux setup (in particular nvim integration remotely)
    - [ ] lua what is userdata vs metatable
    - [ ] default program
        - [ ] zsh is not the nix-env one!
    - [x] vi mode in copy mode
    - [x] vi rectangular selection
    - [x] copy paste in copy mode
    - [ ] remove default mappings
    - [ ] navigation in nvim
      - [ ] nvim inside TMUX (find the right escape code)
    - [ ] search
    - [ ] reload config

    - [ ] Session navigation
  - [ ] check how it works on Linux, you probably need to do the same `ld` hack than on Alacritty to use the LibGL
  - [ ] contribute to:
    - [ ] add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722
    - [ ] add pane-is-zoomed or pane-info to the cli

- shells (for nix setup):
  - [ ] add git completions with nix (understand whether you should add
   .nix-profile/share/git/contrib/completion/ to the fpath or source .nix-profile/share/git/contrib/completion/git-completion.zsh
  - [ ] setup bash completions by linking
    ~/.nix-profile/share/bash-completion/completions

- docker:
  - mv install-docker.sh close to the Dockerfile, add in README docker command to build it from the root of this repo

- updates:
  - [ ] install unixtools (find a good way to discrimate between MacOS X and Linux since unfortunately not all unixtools are available for Darwin, it seems that unixtools is more of a convenience for build script rather than something you should depend on)
  - [x] understand caching for fonts
  => nothing really - to reset you can just reboot laptop
  It does not follow links, you need to copy fonts - kinda sucks https://apple.stackexchange.com/questions/446227/can-you-install-fonts-by-symlinking-them-into-library-fonts
  ```sh
  # Just Do (-L to follow links to target and not copy symlinks themselves - since it does not work on Mac)
  cp -Lr ~/.nix-profile/share/fonts/* ~/Library/Fonts/
  # you might need to resetart laptop
  ```

  - [x] use alacritty-themes from nixpkgs

  - [x] install gnu tools
    - [x] coreutils
    - [x] findutils
    - [ ] ???

  - [x] understand nix's by-name package new structure and automatic addition to all-package
    => added in specific overlay (check `top-level/stages.nix`)

  - [x] configure karabiner
    - idea #1:
      - use karabiner to remap (if possible only in Alacritty and Terminal):
        - right option -> right ctrl
        - right command -> right option
    - idea #2:
      - use karabiner to remap (if possible only in Alacritty and Terminal):
        - right option -> right ctrl
        - right command -> right option
        - left command -> left option
        - left option -> left command
        - override command + shift + v to paste
        - override command + tab to

  - [x] understand alacritty for spotlight
    => seems like you just need to copy it there cf. https://github.com/nix-community/home-manager/issues/1341#issuecomment-2748323255
       spotlight does not follow links, MacOS seems painful on that issue
       ```sh
       # -L to follow links (when using GNU cp)
        cp -rL ~/.nix-profile/Applications/* ~/Applications/
       # ideally we should use rsync to prevent recopying everything after a reinstall
       # cf. what nix-darwin does at https://github.com/nix-community/home-manager/issues/1341#issuecomment-2748323255
       ```

  - [/] install Karabiner with nix for macOS?
    - won't do, no time to get into MacOS custom installation (several disks, locked permissions) + all of this might evolve in the future

  - [ ] update nvim-treesitter, fold is broken

  - [ ] MacOs install script:
    - install Karabiner manually
    - add link to `~/.nix-profile/Applications/Alacritty.app` in `~/Applications/` (for Spotlight to be able to find it, there could have been 2 issues:
    - use rsync for that
    ```sh
    # We use -L with cp below because MacOS does not follow sym links for these funcionalities
    # A better approach could resort on using `rsync` with the options that nix-darwin uses https://github.com/nix-community/home-manager/issues/1341#issuecomment-2748323255

    # Make applications available from launchpad and spotlight
    cp -rL ~/.nix-profile/Applications/* ~/Applications/ # check if you need the -rL if cp with gnu tools

    # Add NerdFonts (you may need to restart for them to appear)
    cp -Lr ~/.nix-profile/share/fonts/* ~/Library/Fonts/
    ```
      - install rust-analyzer, cargo through rustup

  - [ ] use last version of stow for now before yours gets ready
    - [ ] test on Linux (@home, when wifi is not an issue)

  - [ ] check if you still need to wrap alacritty in a script on Linux (and update notes to explain chain lib dependency)

  - [ ] notes on install of nix in the first place to get started
    - [ ] for MacOS
    - [ ] for Linux

  - [ ] check nix-update script if that could work (`niv` does not seem to be maintained so actively :-( )

- [ ] install json5 (to convert from `json5` to `json`), it is a simple node module, but you need to write the derivation for it ...

- develop your own stow version in Rust:
    - [x] init project
    - [x] implementation:
    - [x] how do you allocate a vector's data on the heap ?
      - [x] read https://fasterthanli.me/series/making-our-own-executable-packer/part-14 and take notes
    - [ ] follow this https://rust-cli.github.io/book/tutorial/index.html - don't get lost in looking up the sources too much
    - [ ] https://veykril.github.io/tlborm/syntax-extensions/source-analysis.html on macros

- other idea of something to do in Rust:
  - a small CLI which allows to output up to N lines to stdout and then pass on the rest (this would allow to print the header and then grep for example for ps, kubectl, readelf etc.) (it's a bit like `tee` basically)

- install scripts:
  - [ ] try to make your setup work with the ./overlay.nix inside ~/.config/nixpkgs
  - [ ] check what git-updater does
  - [ ] arguments whether you are installing it on a local machine or remotely
  - [ ] distinguish whether we are running on Debian or MacOS X to set up the various links (fonts, launch menu, etc.)
  - [ ] add a little shell script to automatically add a neovim plugin:
  ```sh
    niv -s ./nix/neovim-plugins/plugins/sources.json add shaunsingh/nord.nvim
    nix-env --install --file nix/default.nix -A neovim-plugin
  ```
  - [ ] create small `init-perso-projects.sh` shell script to be installed as a binary with nix which would clone:
  ```
  git clone git@bitbucket.org:paul_roseau/hlx-gcp-infrastructure.git
  git clone https://github.com/aylei/leetcode-rust.git
  git clone git@github.com:paulroseau/nand2tetris
  git clone git@bitbucket.org:paul_roseau/resume.git
  git clone git@github.com:paulroseau/rust-executable-packer.git
  git clone git://g.csail.mit.edu/xv6-labs-2020
  ```
  - [ ] check whether rustup actually downloads rust-analyzer directly or not when first called otherwise:
  ```sh
  rustup component add rust-analyzer
  ```

- tmux:
  - [x] read https://tao-of-tmux.readthedocs.io
    - [x] checkout tmux capture-pane, tmux save-buffer
      -> ok capture-pane saves you from getting into copy-mode and selecting
      -> to paste you can use `Prefix+]` or use `:paste-buffer`, you can also send it to stdout
  - [ ] make status bar pretty
    - status line can print output of a command at regular interval
    - checkout https://medium.com/hackernoon/customizing-tmux-b3d2a5050207 for more help
    - checkout https://tao-of-tmux.readthedocs.io/en/latest/manuscript/09-status-bar.html
    - looks like the only nice on-the-shelf thing for that is powerline, let's see how it plays, you can also toggle the status bar on and off, but I guess you want it always there
    - would be nice to style the window list as well, not sure powerline can do that
    - maybe powerline is overkill (gadget), but check if you can setup some nice colors
  - [ ] set the window name to cwd by default (dynamically?)

- theory:
  - [ ] how does FFI work
  - [ ] how does a Rust program handle signals, are the handlers set by exec?
  - [ ] read about https://computationstructures.org/lectures/interrupts/interrupts.html :
    - how do we keep up with interrupts? Example of a network card bombing the system
    - how is the interrupt wire checked at each cycle?
    - which PC is saved when interrupted? how do we make sure some instructions are complete
  - [ ] update the notes on ComputerArchitecture especially about asynchronous IOs
  - [ ] once that is done explore libluv and understand how IOs are handled
  - [ ] then you should be able to understand flatten.nvim with the use of
  sockopen and pipes which maps to libuv under the hood (decompose all the way
  down to the processor level)
  - [ ] understand the pipe / NVIM env variable

- neovim:
  - [x] maybe update how you expand windows, and swap the effect of the keys `<` and `>` when on a right most window and `+` and `-` when on a bottom window
  - [ ] create a fzf lua source which prints the current servers capabilities :lua vim.print(vim.lsp.get_active_clients()[1].server_capabilities)
  - [x] replace nvim-cmp by https://github.com/Saghen/blink.cmp
  - [ ] try indent-blankline.nvim
  - [x] do you still need lspconfig in nvim 0.11? -> NO
  - [ ] setup formatting (autoformatting?) for all relevant filetype. Options are:
    - rely on vim.lsp.buf.format() (works only if server supports formatting, check it with `:lua vim.print(vim.lsp.get_active_clients()[1].server_capabilities)` for rust, python, sh, etc. It seems that you need to see
  `documentFormattingProvider = true,` in the results
    - setup a `formatprg` and `formatoptions` in a personal `./ftplugin`
    - add information to lsp.md nodes about this
    - questions:
      - we probably want to map gq to *vim.lsp.buf.format()* if it works (check
      - how can the formatter pick up local options to the project? if the lsp.format works then ok, but in the case where it is not??
  - [ ] try nvim-tree instead of neotree - not sure it is better, but neo-tree is slow, background a bit weird, too configurable, nvim-tree looks simpler
  - [ ] try noice.nvim
  - [ ] install LSP for Rust:
    - [x] rust-analyser and other tools (cargo, etc.) with nix
    - [x] setup lspconfig
    - [x] setup auto formatting with rustfmt
    - [x] see if you want to use other tools such as the one listed here https://github.com/neovim/nvim-lspconfig/wiki/Language-specific-plugins:
      - https://github.com/mrcjkb/rustaceanvim
      - https://github.com/Saecki/crates.nvim
