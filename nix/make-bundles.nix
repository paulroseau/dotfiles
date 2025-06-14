pkgs:

with pkgs;

rec {
  # for a more uniform experience across MacOS X and Linux
  core = [
    coreutils
    findutils
  ];

  nerd-fonts = [
    pkgs.nerd-fonts.agave
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.hurmit
    pkgs.nerd-fonts.terminess-ttf
  ];

  terminal = [
    pkgs.alacritty  # TODO remove this
    alacritty-theme # TODO remove this
    nerd-fonts
    wezterm
  ];

  nix = [
    niv
    pkgs.nix
  ];

  zsh = [
    pkgs.zsh
    starship
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  macos = [
    karabiner-elements
  ];

  neovim = [
    neovim-unwrapped
    neovim-plugins
  ];

  fzf-lua-required = [
    bat
    delta
    fd
    skim
    ripgrep
  ];

  kubernetes = [
    k9s
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
    jaq
    tmux
    tree
    stow
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

    json = [
      vscode-langservers-extracted
    ];

    lua = [
      lua-language-server
    ];

    nix = [
      nil
    ];

    rust = [
      rustup
    ];

    python = [
      pyright
    ];

    terraform = [
      terraform-ls
    ];

    all =
      c ++
      go ++
      json ++
      lua ++
      nix ++
      python ++
      rust ++
      terraform;
  };

  google = [
    google-cloud-sdk
  ];

  base =
    core
    ++ misc
    ++ nix
    ++ neovim
    ++ fzf-lua-required
    ++ zsh;

  work =
    base
    ++ kubernetes
    ++ versioning
    ++ networking
    ++ development.all;

  local = 
    base
    ++ terminal;
}
