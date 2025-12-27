final: prev:

let
  sources = import ./sources.nix {
    pkgs = prev;
    sourcesFile = ./sources.json;
  };

in
{
  alacritty = final.callPackage ./packages/alacritty.nix { alacritty = prev.alacritty; };

  neovim-unwrapped = final.callPackage ./packages/neovim.nix {
    neovim-unwrapped = prev.neovim-unwrapped;
    source = sources.neovim;
  };

  neovim-plugins = final.callPackage ./packages/neovim-plugins {
    neovimPluginsSources = import ./sources.nix {
      pkgs = prev;
      sourcesFile = ./packages/neovim-plugins/plugins/sources.json;
    };

    treeSitterParsersSources = import ./sources.nix {
      pkgs = prev;
      sourcesFile = ./packages/neovim-plugins/tree-sitter-parsers/sources.json;
    };
  };

  # NB: we now decided to rely on rustup which handles the installation of
  # rust related tools, rust-analyzer being one of them, but because the
  # following was hard to get right we are keeping it around, you can always
  # install it with:
  # nix-env -f <nixpkgs> --install -A rust-analyzer
  # but we removed it from the development.rust bundle
  rust-analyzer = final.callPackage ./packages/rust-analyzer.nix {
    rust-analyzer = prev.rust-analyzer;
  };

  update-my-repos = final.callPackage ./packages/update-my-repos/pkg.nix { };

  excalidraw = final.callPackage ./packages/excalidraw.nix { };

  bundles = import ./bundles.nix final;
}
