pkgs:

with pkgs;

rec {
  alacritty = [
    alacritty-themes
    nerdfont
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
    pkgs.neovim
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

  misc = [
    # git # not working on Google laptop
    jq
    lazygit
    tig
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

    all = c ++ lua ++ go;
  };

  base = 
    misc
    ++ nix 
    ++ neovim 
    ++ fzfLuaRequired 
    ++ zsh;

  local = alacritty ++ base;
}
