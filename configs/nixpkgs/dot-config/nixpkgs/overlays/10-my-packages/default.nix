self: super:

let
  sources = import ./sources.nix {
    pkgs = super;
    sourcesFile = ./sources.json;
  };

in
{
  alacritty = self.callPackage ./packages/alacritty.nix { alacritty = super.alacritty; };

  neovim-unwrapped = self.callPackage ./packages/neovim.nix {
    neovim-unwrapped = super.neovim-unwrapped;
    source = sources.neovim;
  };

  neovim-plugins = self.callPackage ./packages/neovim-plugins {
    neovimPluginsSources = import ./sources.nix {
      pkgs = super;
      sourcesFile = ./packages/neovim-plugins/plugins/sources.json;
    };

    treeSitterParsersSources = import ./sources.nix {
      pkgs = super;
      sourcesFile = ./packages/neovim-plugins/tree-sitter-parsers/sources.json;
    };
  };

  # NB: we now decided to rely on rustup which handles the installation of
  # rust related tools, rust-analyzer being one of them, but because the
  # following was hard to get right we are keeping it around, you can always
  # install it with:
  # nix-env -f <nixpkgs> --install -A rust-analyzer
  # but we removed it from the development.rust bundle
  rust-analyzer = self.callPackage ./packages/rust-analyzer.nix {
    rust-analyzer = super.rust-analyzer;
  };

  bundle = import ./make-bundles.nix self;
}
