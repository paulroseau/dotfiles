# Neovim

- [ ] update nvim-treesitter + incremental selection (check MeanderingProgrammer alternative)
- [x] update tabs for it not to show numbers when pop up autocomplete shows up
- [x] install Solarized
- [x] install codecompanion
- [ ] configure codecompanion (probably need to learn a bit about the AI tooling ecosystem)
  - [ ] create alternative to `CodeCompanionActions`, because we want to be able to choose how to open chats (vert, bottom, tab) but we can't do that with a heterogenous list of actions (some trigger other pickers, one is inline, others open a chat buffer). The idea is to have the following:
    - [ ] cycle through the already open chats, seems like we could reuse `fzf.buffer` -> no manual for more control (display the type of adapter at least using `_G.chat_metadata`. You will need to use `fzf_lua.exec(contents, opts)` with `opts._fmt.from = function(s, _) return '[buf_nb]' end`)
      - [x] how are buf lines printed all nice nice (`<leader>l`?), understand coroutine, seems to be the same as python
      - [ ] create commmand
      - [ ] create mapping
      - [ ] summarize the conversation asynchronously (use _ctx) to display:
        it seems like you could hook yourself to the `User` event fired through `utils.fire` from `ChatSubmitted`, check if there is a title on your buffer, if not fire the request in a separate command, passing the context - maybe use treesitter to capture: go to first "## Me" and capture 3 times `##`, `## Me`, `## Me <text>`, and then invoke CodeCompanion Inline "summarize ..." and unconditionally accept the result in a scratch buffer that you keep around just for that purpose, or delete immediately after rather
    - [ ] cycle through the chat creation option: create empty chat, chat with memory, predefined workflow, create git message
    - [ ] cycle through the inline strategies (empty, `/Fix`, etc.)
    - [ ] cycle through the open chats whithin the open window
    - [ ] in this same occasion add other fzf pickers:
      - [ ] toggle ignore files with fzf.files
      - snacks:
        - [ ] projects (is it necessary now that there is zoxide?)
        - recent files
        - undo
        - check out if there are any others
  - [ ] take notes on CodeCompanion architecture
  - [ ] configure Claude
- [ ] checkout this guy's repos and dotfiles https://github.com/olimorris/onedarkpro.nvim he also does codecompanion:
  - his colorschmeme, fonts style, tab bar are really nice on the README screen records
  - [ ] install nvimdev/dashboard
  - his plugins are (should you use them?):
    - [ ] his onedarkpro -> YES
    - [ ] switch from lualine to heirline, and remove your tabline plugin -> YES
    - [ ] copilot
    - [ ] oil -> Probably NO
    - [ ] mini.test
    - [ ] aerial
    - [ ] persisted
    - [ ] overseer
    - [x] mason -> No
    - [ ] conform
    - [ ] ufo
    - [ ] troublesum
    - [ ] nvim-autopairs
    - [ ] guess-indent
    - [x] todo-comments -> No
    - [ ] render-markdown
    - [ ] edgy
    - [ ] gitsigns
    - [ ] snacks -> Not as a whole but see below
  - [ ] transition to vim.pack (0.12) but already there in nightly, requires `git`, but nicely enough should write plugins `$HOME/.local/share` (so nix compatible):
    - [ ] remove neovim plugins from nix
    - [ ] update install.sh
- [ ] check snacks:
  - [x] file explorer -> mouais, not convinced neo-tree is better
  - [x] same for picker, fzf-lua better
  - [ ] picker -> not a fan, but there is search projects, recent files, undo which are really nice
  - [ ] check how snacks implement toggling
  - [ ] rework mapping like snacks default
- [ ] undo tree
- [ ] install https://github.com/jackMort/ChatGPT.nvim (make sure you can start if no API key is found and DO NOT PUSH your api key to Github)
- [ ] check plugins listed on lazyvim (in particular conform for formatting, dashboard)
  - [ ] for conform see if you need to install prettier, if so add it with nix (not in nixpkgs)
- [ ] rework your smart windows by separating configuration/initialization (ie. no setup(config)): https://github.com/nvim-neorocks/nvim-best-practices?tab=readme-ov-file#sleeping_bed-lazy-loading
- [ ] allow to specify count in the mapping to resize window (like typing 20 and <M->> should resize by increment * 20)
- [ ] add luacats annotations in your config: https://luals.github.io/wiki/annotations (also for wezterm)
- [ ] review all dos and don'ts in https://github.com/nvim-neorocks/nvim-best-practices
- [ ] fix clangd
- [ ] would be great if <C-s> could reveal the signature help window, which would remain there until we type <C-s> again (if there were a vim.lsp.buf.signature_help_toggle())
- [x] maybe update how you expand windows, and swap the effect of the keys `<` and `>` when on a right most window and `+` and `-` when on a bottom window
- [ ] create a fzf-lua source which prints the current servers capabilities :lua vim.print(vim.lsp.get_active_clients()[1].server_capabilities)
- [x] replace nvim-cmp by https://github.com/Saghen/blink.cmp
- [ ] try indent-blankline.nvim
- [x] do you still need lspconfig in nvim 0.11? -> NO
- [ ] setup formatting (autoformatting?) for all relevant filetype. Options are:
    - rely on vim.lsp.buf.format() (works only if server supports formatting, check it with `:lua vim.print(vim.lsp.get_active_clients()[1].server_capabilities)` for rust, python, sh, etc. It seems that you need to see
    `documentFormattingProvider = true,` in the results
    - setup a `formatprg` and `formatoptions` in a personal `./ftplugin`
    - add information to lsp.md nodes about this
    - questions:
      - we probably want to map gq to *vim.lsp.buf.format()* if it works (check how can the formatter pick up local options to the project? if the lsp.format works then ok, but in the case where it is not??
- [ ] try nvim-tree instead of neotree - not sure it is better, but neo-tree is slow, background a bit weird, too configurable, nvim-tree looks simpler
- [ ] try noice.nvim
- [x] install LSP for Rust:
  - [x] rust-analyser and other tools (cargo, etc.) with nix
  - [x] setup lspconfig
  - [x] setup auto formatting with rustfmt
  - [x] see if you want to use other tools such as the one listed here https://github.com/neovim/nvim-lspconfig/wiki/Language-specific-plugins:
    - https://github.com/mrcjkb/rustaceanvim
    - https://github.com/Saecki/crates.nvim

- NB: on hover and signature help, monitor this issue: https://github.com/neovim/neovim/issues/28140 which asks for the ability to toggle the preview window (links to this more general issue: https://github.com/neovim/neovim/issues/31206), right now you just map K to calling vim.lsp.buf.hover twice, but you would still need to press `q` to exit, ideally we just exit with `K` as well

# Tmux

- [x] read https://tao-of-tmux.readthedocs.io
- [x] checkout tmux capture-pane, tmux save-buffer
  -> ok capture-pane saves you from getting into copy-mode and selecting
  -> to paste you can use `Prefix+]` or use `:paste-buffer`, you can also send it to stdout
- [x] resize windows by more increments
- [x] make status bar pretty:
  - [x] use conditionals (from `man tmux`) and fg/bg colors
    - [x] see if you can make the nvim_mode just a flag and not a string
    - [x] make use of `set-option -ag` to append
    - [x] make use of window-status-activity, etc. for the window display (set the window name to cwd by default dynamically)
    - [-] add cpu/ram: (requires external script probably - think about how to integrate this in nix and manually ...)
      -> won't do because this makes your tmux conf relying on the presence of an extra script + this script would need to test if we are on MacOS or Linux, rely on awk, etc. this makes it fragile. In an ideal world, we would have something akin to starship, which could be configured in lua (exposes cpu, mem, current working directory of a process, etc.) and output the status-left, status-right and window-status-activity strings. Also it could take a theme as an input.
- [-] create some fuzzy finding with fzf for searching through sessions & tabs
  -> hard to get right and maintainable without external script again
- [ ] see what you can do for panes (pane border style, etc.)
    - useful link: https://arcolinux.com/everything-you-need-to-know-about-tmux-status-bar/
    - status line can print output of a command at regular interval

# Rust binary to develop ideas

## Small (S)

- [ ] super simple `icon4` which reads ~/.proc2icon config file which would be a json file (ideally lua though) which returns
    ```json
    {
        "nvim": "",
        "zsh": ""
    }
    ```
    would be useful for `tmux` status window to:
    ```
    set-option -ag window-status-format "#(icon4 #{pane_current_command}) #(basename #{pane_current_path}) "
    ```
- [ ] a small CLI which allows to output up to N lines to stdout and then pass on the rest to a pipe
  - this would allow to print the header and then grep for example for ps, kubectl, readelf etc. (a bit like `tee` basically)

## Medium (M)

- [ ] rust reimplem of your update-my-repos, with:
  - asynchronous downloads and nice lines
  - config generations handling upgrade strategies (last commit, next_semver, last_semver, last_release)

## Medium (M)

- [ ] rust reimplem of `stow`, (look into what chez-moi does, do not go as far as chezmoi which downloads binaries, but with the apply logic, possiblity to copy -r, link and revert):
  - [ ] finish the nomicon
  - [ ] follow this https://rust-cli.github.io/book/tutorial/index.html - don't get lost in looking up the sources too much
  - [ ] https://veykril.github.io/tlborm/syntax-extensions/source-analysis.html on macros

- [ ] rust app/library which gives you the current CPU, Memory, Disk, Network and battery usage across Linux, MacOS, Windows - could be useful for tmux, and Wezterm could depend on it

- [ ] a utility to generate a beautiful status bar in TMUX which would be configured in lua

## Extra Large (XL)

- [ ] fork of Wezterm to address the issues below:
  - [ ] simplify the menu logic, make a modal feature and fuzzy find over whatever
  - [ ] understand the relationship between format-tab-title and the title of a tab to be able to fuzzy find through those
  - [ ] get the process name for remote processes
  - [ ] fix copy paste when happening remotely
  - [ ] improve Copy Mode
  - [ ] maybe add a Command mode

- [ ] OR Your own TMUX that could:
  - be configured in lua
  - have nerdfonts embedded
  - have colorscheme embedded
  - have a fuzzy finder embedded and be a first class citizen to select stuff
  - be able to multiplex across machines
  => basically a fork of Wezterm, but without: the weird launch menu, the UI tabline, focus events, maybe rework the architecture (event/async) to allow async calls in the tabstatus, configurarble keyspace for command line, copy mode (better vi/emacs support), etc.

# Chezmoi

- [x] Look into it to set the symlinks, and replace manual install
  -> mouais not convinced, you end up writing go template instead of bash, not really cleaner, what would be useful is the management and rollback of configs, secret encryption but `stow` should be good enough for now

# Office setup

- [x] install wezterm manually (zipfile) or winget?
- [x] copy your wezterm config
- [x] install coder and configure cli
  ```
  winget install Coder.Coder
  coder login http://...
  coder config-ssh
  ssh coder.<...>
  ```
- [x] install wezterm on remote Linux image (cf. wezterm)
- [ ] rework `install-manual.sh`
  - [ ] check out chezmoi seriously first, otherswise:
  - [ ] separate all binaries versions in a separate file
  - [ ] separate installation of each binary
  - [ ] split in several scripts? -> not sure

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

# Alacritty

- [ ] <Meta + Shift> does not work outside of Tmux (cannot resize nvim windows)
  -> this is annoying, Karabiner shows that all 3 <left-option>/<left_shift>/<.> are pressed just like on wezterm, but it is like Alacritty suppresses it. However Tmux running inside alacritty catches it
- [x] default program
  - [x] on MacOS the default PATH is prepended, so /bin/zsh is started instead of the nix one. Modifications to the path are not taken into account unless you launch it via command line (for which karabiner does not work ...)
  -> potential solution, wrap it in Nix
  -> no need fixed on MacOS, probably thanks to the fact that Alacritty launches zsh by default and hence picks up on zshrc (updates the $PATH environment variables by prepending `/Users/polo/.nix-profile/bin:/Users/polo/.local/bin`) cf:
  - https://github.com/alacritty/alacritty/issues/8535
  - https://github.com/chrisnc/alacritty/blob/6566dd3defa9f080dabb295740dc1dac06e3b8fb/alacritty_terminal/src/tty/unix.rs#L131-L150

# Yazi

- remap using <A-J/K> for changing windows and `J`/`K` for changing tabs cf. https://yazi-rs.github.io/docs/configuration/keymap and `(/)` for swapping tabs https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/keymap-default.toml -> `<M-j>/<M-k>` is taken by Wezterm changing windows

# Wezterm

## Install

- [x] Rabbit-hole #1: how does wezterm link to `lua.so` when built with nix? It looks like lua.so is looked up dynamically with pkg-config, so explore:
  - [ ] pkg-config
  - [ ] pkg-config on nix
  - [ ] wezterm building on nix
    => wezterm uses the vendored lua code, so pkg-config is irrelevant here

## Tab bar

- [ ] Wezterm: prettier tabs and statusline: https://github.com/michaelbrusegard/tabline.wez (for status line print Nvim icon if nvim_mode is on but nvim_ignore is off)
  - [x] fix swapping on right side
  - [x] set up tab rendering
  - [x] factorize even further the components.init (explicit arguments not an {} for each function and handle the args unwrapping in there)
  - [x] make the map for all components programmatically launch require('tabline.components' .. name) (if it fails return nil), through a setmetatable({}, {__index = function(k, t)})
  - [x] allow to customize tabs colors & attributes (test with a rainbow)
  - [x] rename section_config.colors in section_config.color_overrides
  - [x] create a constant component (need to pass args from config - not rendering options)
  - [x] pass down the parameter for tab numbering from config (config.setup)
  - [x] overrides colors for Solarized and one dark (surface, middle_tab_bar)
  - [x] reload tab bar dynamically when changing colorscheme
  - [ ] convert all old components (just need the last 3): <- BACK HERE
    - [ ] cpu
      - [x] implem
      - [x] add space to move the percent sign -> ok %% is to escape %, but stuck is better
      - [ ] fix on Windows
    - [ ] ram
      - [x] implem
      - [ ] fix on Windows
    - [x] process
    - [ ] issue with process, does not work on remote tab, understand multiplexing better, set it up (local socket?), and test
      - [x] test at the office
      - [ ] test with a Linux box on GCP
  - [x] test all existing components in the tab (just need the last 3)
  - [x] add nvim-mode component and put it in position `x` (right side)
  - [x] remove old tabline and rename my-tabline to tabline
  - [-] add time with timezone -> (won't do, not available natively, would need to fork process)

## Windows / remote setup

- [ ] issue with the clipboard:
  - you need to use
  ```lua
  vim.g.clipboard = 'osc52'
  vim.o.clipboard = 'unnamedplus'
  ```
  but the issue is that wezterm can *write* fine to the terminal clipboard through the `osc52` sequence but it cannot read from it! Hence `p` (for paste in neovim blocks)
  people are aware of the issue: https://github.com/wezterm/wezterm/issues/2050 and there is even a PR for it: https://github.com/wezterm/wezterm/pull/6239 but not reviewed for the last 10 months. Otherwise we can make a workaround to paste directly from nvim registers and resort to `Ctrl+Shift+V` to paste from clipboard
- [x] nvim is glitchy (screen is not recomputed properly, especially on repeat keys, but not only, eg. expanding neo-tree next to an empty buffer)
  -> fixed in nightly
- [x] install wezterm mux server inside docker at work. Possible strategies:
  - [x] build it headless with the following command:
  ```sh
  mkdir -p ${HOME}/sources
  pushd ${HOME}/sources
  git clone https://github.com/wezterm/wezterm.git
  pushd wezterm
  git checkout 20240203-110809-5046fc22 # finally no, get the nightly tag
  echo '1.78.0' > rust-toolchain # might need to make sure the toolchain is installed before
  cargo build --release --package wezterm --package wezterm-mux-server
  popd
  popd
  # crate links
  ```
  - [x] test use wezterm ssh
  ```ps1
  C:\Users\proseau\AppData\Local\Microsoft\WinGet\Packages\Coder.Coder_Microsoft.Winget.Source_8wekyb3d8bbwe\coder.exe port-forward proseau/eu-west-1 --tcp 127.0.0.1:2222:22
  # direct ssh
  C:\Users\proseau\apps\WezTerm-windows-20240203-110809-5046fc22\wezterm.exe ssh coder@127.0.0.1:2222

  # ssh domains
  C:\Users\proseau\apps\WezTerm-windows-20240203-110809-5046fc22\wezterm.exe connect eu-west-1
  ```
  - [x] test use wezterm connect (probably need a port-forward dance for the mux-server)
  - [x] fix neovim change windows remotely
  - [x] handle the PATH on Windows to simplify the above commands, add coder + wezterm (coder was already done, wezterm added manually)
- [ ] Productionize the above item (`install-manual.sh` etc.)
  - [ ] see if you can avoid spawning 2 windows, or show only the windows from the current domain (maybe assign a workspace), maybe finalize the picker here
- [ ] launch zsh if available for eu-west-1 domain
  -> the issue comes from the entrypoint being `bash -l` which does not read .bashrc, you could find a temporary workaround but probably this will be the start of creating your own image

## Picker

- [ ] Consider using the Input select for switching:
  - [x] fonts
    - [x] include only fonts that are available inside ~/.fonts (question: why not check nix directly? I guess this leaves us room to download fonts directly there, to think about it)
  - [x] colorschemes
  - [x] workspaces
  - [ ] tabs
    - [x] need to rework my-tabline to set the title (mark fields to be included? how to concatenate them)
    - test in debug mode with:
    ```lua
    window = wezterm.mux.all_windows()[1]
    tab = window:tabs()[1]
    tab:get_title()
    ```
    - [ ] using `set title` on top of returning the formatted string in the `format-tab-title` event is an issue remotely
  - [ ] domains
  - [ ] Refacto:
    - [ ] extra-action split in 2:
      - [ ] better copy mode
      - [ ] focused-in events
  -> checkout those to get inspiration, but you probably will define your own selector (not just for domains, workspaces, but also fonts etc.)
    - https://github.com/MLFlexer/smart_workspace_switcher.wezterm/blob/main/plugin/init.lua
    - https://github.com/DavidRR-F/quick_domains.wezterm
    - https://github.com/mikkasendke/sessionizer.wezterm (maybe the closest to your need)
  -> use the table trick to display clean values / make the selector its own lua module
  -> issue with for color_scheme (config_overrides) when creating new workspace it keeps the setting (looks like a bug)
    - [ ] Create a domain dynamically ? needs to be added to wezterm -> no but prepare a config file to edit, test with docker container or VM

- Wezterm missing:
  - Closing a workspace at once (not supported natively, lots of lua code cf. https://github.com/wezterm/wezterm/issues/3658, not worth it)
  - contribute to add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722

- Wezterm Big issues at the moment:
  - search not intuitive, selection by default also when you come back, case sensitivity, there should be only 1 copy mode
  - missing choose-tree, more uniform menus
      import pane/tab from elsewhere (need choose-tree)
  - missing focus pane events
  - set title bug, what is returned by the format-tab-title event should be the title
  - missing active key changed event
  - export pane/tab to new workspace (1 window/workspace)
  - move pane/tab to new workspace (1 window/workspace)
  - customizable keymaps in menu mode and search mode (editing part, emacs style would be good by default)
  - better vim movements in Copy Mode (e not respected, E, etc.)
  - foreground process from remote tabs

- Wezterm potential enhancement:
  - change layout like in nvim, right now you can just rotate panes
  - have a command line (vim style? C-a : and C-a /) with either emacs or vim mappings, but with keys still customizable
  - have an unlock key like in zellij

- Wezterm:
    - [ ] configure multiplexing session and check that clipboard is working fine
  - Karabiner:
    - [ ] check if conditions for karabiner could not be factored out
    - [x] find how to apply changes to when wezterm is launched from the command line -> use FilePath instead of bundle identifier
  - Default program:
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
  - [ ] check how it works on Linux, you probably need to do the same `ld` hack as on Alacritty to use the LibGL
  - [ ] contribute to:
    - [ ] add `Ctrl-C` to exit launcher, super-mini change: https://github.com/wezterm/wezterm/issues/4722
    - [ ] add pane-is-zoomed or pane-info to the cli

# Shells

- for nix setup:
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

# Nix setup

- install scripts:
  - [x] try to make your setup work with the ./overlay.nix inside ~/.config/nixpkgs
  - [ ] check what git-updater does
  - [ ] check out https://github.com/cachix/git-hooks.nix
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

# Theory

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
