pkgs:

with pkgs;

rec {
  alacritty = [
    alacritty-theme
    nerdfonts
    pkgs.alacritty
  ];

  nix = [
    niv
    pkgs.nix
  ];

  zsh = [
    pkgs.zsh
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  neovim = [
    pkgs.neovim-unwrapped
    neovim-plugins
  ];

  fzfLuaRequired = [
    bat
    delta
    fd
    fzf
    ripgrep
  ];

  kubernetes = [
    # k9s # not working on Google laptop, needs to be compiled with patched go
    kubectl
    kubectl-tree
  ];

  versioning = [
    # git # not working on Google laptop
    lazygit
    tig
  ];

  networking = [
    ipcalc
  ];

  misc = [
    jq
    tmux
    yq
  ];

  development = rec {
    c = [
      clang
      clang-tools
      cmake
    ];

    go = [
      gopls
    ];

    lua = [
      lua-language-server
    ];

    rust = [
      rustup
    ];

    python = [
      pyright
    ];

    all =
      c ++
      go ++
      lua ++
      python ++
      rust;
  };

  google = [
    google-cloud-sdk
  ];

  base =
    misc
    ++ nix
    ++ neovim
    ++ fzfLuaRequired
    ++ zsh;

  local = alacritty ++ base;
}
