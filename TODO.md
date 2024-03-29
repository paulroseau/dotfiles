- develop your own stow version in Rust:
  - [x] init project
  - [ ] implementation

- install script:
  - [ ] arguments wether you are installing it on a local machine or remotely
  - [ ] distinguish whether we are running on Debian or MacOS X to set up the various links (fonts, launch menu, etc.)

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

- theory:
  - [ ] read about https://computationstructures.org/lectures/interrupts/interrupts.html
  - [ ] update the notes on ComputerArchitecture especially about asynchronous IOs
  - [ ] once that is done explore libluv and understand how IOs are handled
  - [ ] then you should be able to understand flatten.nvim with the use of
  sockopen and pipes which maps to libuv under the hood (decompose all the way
  down to the processor level)
  - [ ] understand the pipe / NVIM env variable

- neovim:
  - [ ] install LSP for Python
  - [ ] install LSP for Go
    - how to disable LSP (useful for big projects like GDCH for instance) -> use LspStop from lspconfig plugin. Check the memory usage of that process, and if it calms down after you stop the client (the server still keeps running)
    - check if you can reference external index for LSP servers (big projects again), basically try to see how it goes with GDCH code base
    - test on gdch code base
  - [ ] install LSP for Scala
  - [ ] install LSP for OCaml
  - [ ] install LSP for Haskell
