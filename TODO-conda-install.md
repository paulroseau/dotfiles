
On conda:
- [ ] zsh:
  - [x] zsh-autosuggestions
  - [x] zsh-syntax-highlighting
  - [x] zsh customization
  - [ ] fzf
    - no plugin manager, fzf does not store zsh scripts in standard location so even antidote cannot find it
    - it is there, probably you will have to split dot-zshrc and dot-bashrc to:
      1. `. /opt/conda/etc/profile.d/conda.sh && conda activate base`
 
  - [-] populate autocomplete folder with sitefunctions
    - uhoh, not downloaded for most of them

- [ ] Setup Windows Terminal with Nerdfonts
  - https://medium.com/@vedantkadam541/beautify-your-windows-terminal-using-nerd-fonts-and-oh-my-posh-4f4393f097

- [ ] Install the following manually:
  - [ ] rustup
  - [ ] tree
  - [ ] lemonade

- [x] Intall the following through conda
  - [x] git
  - [x] bat
  - [x] delta (git-delta)
  - [x] fd (fd-find)
  - [x] fzf
  - [x] jq
  - [x] pyright
  - [x] python
  - [x] ripgrep
  - [x] starship
  - [x] stow
  - [x] tmux
  - [x] zsh
  - [x] neovim:
    - [x] handle plugins with lazy -> NO make a shim
    - [x] handle treesitters grammar with nvim-treesitter
