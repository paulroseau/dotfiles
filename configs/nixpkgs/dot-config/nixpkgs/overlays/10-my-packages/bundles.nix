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
    nerd-fonts
    wezterm
  ];

  shell = [
    zsh
    starship
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  neovim = [
    neovim-unwrapped
    neovim-package
  ];

  fzf-lua-required = [
    bat
    delta
    fd
    fzf
    ripgrep
    skim
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

  networking = [ ipcalc ];

  misc = [
    jaq
    tmux
    tree
    stow
    yazi-unwrapped
    yq
  ];

  ai = [
    claude-code
  ];

  development = rec {
    c = [
      clang
      clang-tools
      cmake
    ];

    go = [
      pkgs.go
      gotools
      gopls
    ];

    web = [
      vscode-langservers-extracted
      prettierd
    ];

    lua = [
      lua-language-server
      stylua
    ];

    nix = [
      nil
      nixfmt
      pkgs.nix
    ];

    rust = [ rustup ];

    python = [
      python3
      pyright
      ruff
    ];

    terraform = [
      pkgs.terraform
      terraform-ls
    ];

    yaml = [ yaml-language-server ];

    all-free = c ++ go ++ lua ++ nix ++ python ++ rust ++ web ++ yaml;

    all = all-free ++ terraform;
  };

  google = [ google-cloud-sdk ];

  base = core ++ misc ++ neovim ++ fzf-lua-required ++ versioning ++ shell;

  local = base ++ terminal ++ development.all-free;
}
