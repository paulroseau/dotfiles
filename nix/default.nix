{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let 
  alacrittyPackages = callPackage ./alacritty.nix {};
  zshPackages = callPackage ./zsh.nix {};
in
  [
    alacrittyPackages
    zshPackages
  ] ++ [
    tmux
  ]
