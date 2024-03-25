pkgs:

with pkgs;

let
  alacrittyPackages = [
    alacritty
    alacritty-themes
    nerdfont
  ];

  developmentPackages =
    let
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
    in
      c
      ++ lua
      ++ go;

  neovimPackages = [
    neovim
    neovim-plugins
  ];

  zshPackages =
    let
      zshPlugins = [
        zsh-autosuggestions
        zsh-syntax-highlighting
      ];

    in [ zsh starship ] ++ zshPlugins;

  binaries =
    let
      nixBinaries = [
        niv
        nix
      ];

      kubernetesBinaries = [
        # k9s # not working on Google laptop, needs to be compiled with patched go
        kubectl
        kubectl-tree
      ];

      miscBinaries = [
        bat
        delta
        fd
        fzf
        # git # not working on Google laptop
        jq
        ripgrep
        tig
        tmux
        yq
      ];
    in
      nixBinaries ++ kubernetesBinaries ++ miscBinaries;

in {
  base =
    binaries
    ++ developmentPackages
    ++ neovimPackages
    ++ zshPackages;

  local = alacrittyPackages ++ base;
}
