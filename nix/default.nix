{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let 
  alacrittyPackages = callPackage ./alacritty.nix {};
  zshPackages = callPackage ./zsh.nix {};
  neovimPackages = callPackage ./neovim {};

  /* 
  Note: 
  Some binaries are necessary/recommended for the telescope.nvim plugin to work properly.

  The plugin expects the binaries to be in the PATH so this is what we do here,
  because we might them elsewhere anyway.

  The cleanest approach would be to patch telescope.nvim to replace occurences of
  those binaries by the full paths such as ${ripgrep}/bin/rg but I can't bother to do that.

  An alternative would also be to wrap the `nvim` executable in a script where we
  override the PATH environment variable to point to just those binaries.
  */
  telescopeRecommendedBinaries = [
    ripgrep
    fd
  ];
in
  [
    alacrittyPackages
    zshPackages
    neovimPackages
  ] 
  ++ telescopeRecommendedBinaries
  ++ [
    # git
    tig
    tmux
    lazygit
    jq
  ]
