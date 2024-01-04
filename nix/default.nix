{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let 
  alacrittyPackages = callPackage ./alacritty.nix {};

  zshPackages = callPackage ./zsh.nix {};

  neovimPackages = callPackage ./neovim {};

  /* 
  Note: 
  Some binaries are necessary/recommended for the fzf-lua plugin to work properly.

  The plugin expects the binaries to be in the PATH so this is what we do here,
  because we might need them elsewhere anyway.

  The cleanest approach would be to patch the plugin to replace occurences of
  those binaries by the full paths such as ${ripgrep}/bin/rg but I can't bother to do that.

  An alternative would also be to wrap the `nvim` executable in a script where we
  override the PATH environment variable so those binaries could be found

  However since we also want to use those binaries on their own, it just makes
  sense to install them directly and not as dependencies of nvim
  */
  fzfLuaBinaries = [
    fzf
    ripgrep
    fd
    bat
    delta
  ];

  miscBinaries = [
    # git # not working on Google laptop
    tig
    tmux
    lazygit
    jq
    yq
  ];

  kubernetesBinaries = [
    # k9s # not working on Google laptop, needs to be compiled with patched go
    kubectl
    kubectl-tree
  ];

in
  [
    alacrittyPackages
    zshPackages
    neovimPackages
  ] 
  ++ fzfLuaBinaries
  ++ miscBinaries
  ++ kubernetesBinaries
