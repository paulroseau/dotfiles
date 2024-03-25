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

  lazygitPinned = lazygit.overrideAttrs (self: super: {
    version = sources.lazygit.rev;
    src = sources.lazygit;
    ldflags = [ "-X main.version=${self.version}" "-X main.buildSource=nix" ];
  });

  myPackages = 
    nixpkgs // 
    alacrittyPackages //
    neovimPackages // {
      lazygit = lazygitPinned;
    };

  packageBundles = import ./bundles.nix myPackages;

in 
  myPackages // packageBundles
