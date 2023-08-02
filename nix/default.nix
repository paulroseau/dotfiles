{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let 
  alacrittyPackages = callPackage ./alacritty.nix {};
  zshPackages = callPackage ./zsh.nix {};
  neovimPackages = callPackage ./neovim {};
in
  [
    alacrittyPackages
    zshPackages
    neovimPackages
  ] ++ [
    # git
    tig
    tmux
    lazygit
    jq
  ]
