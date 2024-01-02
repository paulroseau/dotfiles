- alacritty
  - [X] add $@ as arguments in the wrapped script so we can pass options and arguments 

- nix
  - [ ] start using `nix` directly instead of `nix-env` and `nix-store`
  - [ ] add nix config to avoid long feature flags
  - [ ] investigate if there is a way to delete old nix-channel user-environment to perform a full `nix-store --gc`

- tmux
  - read https://tao-of-tmux.readthedocs.io
  - make status bar pretty

- neovim
  - [ ] Check youtube series on Lunar Nvim (distro): https://www.youtube.com/playlist?list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ
    - [X] 1. Intro: term toggler looks interesting
      - nothing new
    - [X] 2. Settings
      - set `splitbelow` and `splitright` to true
    - [X] 3. Keymaps
      - nothing new
    - [ ] 4. Plugins (about packer)
    - [X] 5. Colorscheme
    - [ ] 6. Neovim - Completion Tutorial 100% Lua
    - [X] 7. Add Icons to your Fonts with Nerd Fonts
      - nothing new
    - [ ] 8. Neovim - LSP Setup Tutorial (Built in LSP 100% Lua)
    - [-] 9. Neovim - Telescope: a highly extendable fuzzy finder -> N/A
    - [ ] 10. Neovim - Treesitter Syntax Highlighting
    - [X] 11. Neovim - From Scratch Q&A
      - checkout neovim awesome
    - [X] 12. Neovim - Autopairs automatically close () [] {} '' ""
      - not sure if we want to install it, I am not a fan of autopairing (we
      could have it setup for certain filetype - programming languages)
    - [X] 13. Neovim - Comments (JSX Commenting support explained)
      - JoosepAlviste/nvim-ts-context-commentstring could be interesting to
      comment nested stuff (code instide of markdown, js inside of html, etc.)
    - [ ] 14. Neovim - Gitsigns Powerful Git Plugin for Neovim
    - [ ] 15. Neovim - NvimTree File Explorer Written In Lua
    - [ ] 16. Neovim - Bufferline Buffers vs Tabs vs Windows Explanation
    - [ ] 17. Neovim - Null-LS Formatting, Linting & more (Supports prettier, black, eslint, flake8 & more)
    - [ ] 18. Neovim - Toggleterm | Open terminal programs in Neovim
  - [ ] configure lua-line
