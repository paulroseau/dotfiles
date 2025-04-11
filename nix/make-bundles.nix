pkgs:

with pkgs;

rec {
  # for a more uniform experience across MacOS X and Linux
  core = [
    pkgs.coreutils
    pkgs.findutils
  ];

  nerd-fonts = [
    pkgs.nerd-fonts.agave
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.hurmit
    pkgs.nerd-fonts.terminess-ttf
  ];

  alacritty = [
    pkgs.alacritty
    pkgs.alacritty-theme
    nerd-fonts
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
    git
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
    core
    ++ misc
    ++ nix
    ++ neovim
    ++ fzfLuaRequired
    ++ zsh;

  local = alacritty ++ base;
}
