- updates:
  - [ ] check if you still need to wrap alacritty in a script on Linux (and update notes to explain chain lib dependency)
  - [ ] notes on install of nix in the first place to get started
  - [ ] use alacritty-themes from nixpkgs

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
  - [ ] check what git-uptdater does
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
  - [ ] try nvim-tree instead of neotree - not sure it is better, but neo-tree is slow, background a bit weird, too configurable, nvim-tree sounds simpler
  - [ ] try noice.nvim
  - [ ] install LSP for Rust:
    - [x] rust-analyser and other tools (cargo, etc.) with nix
    - [x] setup lspconfig
    - [ ] setup auto formatting with rustfmt
    - [ ] see if you want to use other tools such as the one listed here https://github.com/neovim/nvim-lspconfig/wiki/Language-specific-plugins:
      - https://github.com/mrcjkb/rustaceanvim
      - https://github.com/Saecki/crates.nvim
  - [x] install LSP for Python
  - [ ] install LSP for Go
    - how to disable LSP (useful for big projects like GDCH for instance) -> use LspStop from lspconfig plugin. Check the memory usage of that process, and if it calms down after you stop the client (the server still keeps running)
    - check if you can reference external index for LSP servers (big projects again), basically try to see how it goes with GDCH code base
    - test on gdch code base
  - [ ] install LSP for Scala
  - [ ] install LSP for OCaml
  - [ ] install LSP for Haskell
