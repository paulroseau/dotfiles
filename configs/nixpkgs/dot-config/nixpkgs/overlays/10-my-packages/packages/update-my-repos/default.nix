let
  pkgs = import <nixpkgs> { };
in
pkgs.callPackage ./pkg.nix {
  pythonPackages = pkgs.python312Packages;
}
