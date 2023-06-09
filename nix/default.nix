{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let 
  alacrittyPackages = callPackage ./alacritty.nix {};
in
  [
    alacrittyPackages
  ] ++ [
    tmux
  ]
