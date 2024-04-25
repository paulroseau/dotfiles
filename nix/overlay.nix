self: super: 

let 
  sources = import ./sources.nix {
    pkgs = super;
    sourcesFile = ./sources.json ;
  };

in 
  {
    nerdfonts = super.nerdfonts.override {
      fonts = [ 
        "Agave" 
        "Hack" 
        "Hermit" 
        "Terminus" 
      ];
    };

    alacritty-theme = 
      super.runCommand "alacritty-theme" {}
      ''
      mkdir -p $out/share/alacritty
      ln -s ${sources.alacritty-theme}/themes $out/share/alacritty
      '';

    alacritty = self.callPackage ./alacritty.nix {
      alacritty = super.alacritty;
    };

    lazygit = super.lazygit.overrideAttrs (self: super: {
      version = sources.lazygit.rev;
      src = sources.lazygit;
      ldflags = [ "-X main.version=${self.version}" "-X main.buildSource=nix" ];
    });

    neovim-unwrapped = super.neovim-unwrapped.overrideAttrs(self: super: {
      version = sources.neovim.rev;
      src = sources.neovim;
    });

    neovim-plugins = self.callPackage ./neovim-plugins {
      neovimPluginsSources = import ./sources.nix { 
        pkgs = super;
        sourcesFile = ./neovim-plugins/plugins/sources.json ;
      };

      treeSitterParsersSources = import ./sources.nix {
        pkgs = super;
        sourcesFile = ./neovim-plugins/tree-sitter-parsers/sources.json ;
      };
    };

    myPkgs = import ./make-bundles.nix self;
  }
