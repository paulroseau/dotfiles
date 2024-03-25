{ nixpkgs 
, sources 
}:

with nixpkgs;

let
  alacrittyPackages = callPackage ./alacritty.nix {
    alacrittyThemeSource = sources.alacritty-theme;
  };

  neovimPackages = callPackage ./neovim {
    inherit sources;
  };


  myPackages = 
    nixpkgs // 
    alacrittyPackages //
    neovimPackages;

  packageBundles = import ./bundles.nix myPackages;

in 
  myPackages // packageBundles
