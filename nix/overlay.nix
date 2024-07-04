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

    # rust-analyzer tries to generate the Cargo.lock file for a project when it
    # is missing. Since the standard library source code does not contain any
    # Cargo.lock files, rust-analyzer crashes because it does not have write
    # permissions on /nix/store/...-rustLibSrc (the nix store is read-only!)
    #
    # Here we create a copy of the rustSrc derivation and override this
    # parameter when deriving rust-analyzer. We don't just overlay on
    # rustPlatform.rustLibSrc because that causes nix to rebuild every rust
    # package rather than pulling those from the cache
    # 
    # NB: we now decided to rely on rustup which handles the installation of
    # rust related tools, rust-analyzer being one of them, but because the
    # following was hard to get right we are keeping it around, you can always
    # install it with:
    # nix-env --install -f ./default.nix -A rust-analyzer
    # but we removed it from the rust bundle
    rust-analyzer = super.rust-analyzer.override {
      rustSrc = super.runCommand "rust-lib-src-with-cargo-lock" {
         # necessary to make this a fixed output derivation so the build can run
         # outside of the sandbox since Cargo needs to fetch dependencies over
         # the network
         outputHashMode = "recursive";
         outputHashAlgo = "sha256";
         outputHash = "sha256-28u+68aY8n/uU/vvZZuyN/pPpTQIG+Tb97IFxQvgcis="; 
       } ''
         mkdir $out
         cp -r ${super.rustPlatform.rustLibSrc}/* $out/
         chmod -R u+w $out/

         # necessary so cargo can validate the SSL certs from crates.io
         export CARGO_HTTP_CAINFO=${super.cacert}/etc/ssl/certs/ca-bundle.crt

         # necessary for cargo to find crates included in the directory tree
         cd $out

         find . -name 'Cargo.toml' -exec ${super.cargo}/bin/cargo generate-lockfile --manifest-path {} \;
       '';
    };

    myPkgs = import ./make-bundles.nix self;
  }
