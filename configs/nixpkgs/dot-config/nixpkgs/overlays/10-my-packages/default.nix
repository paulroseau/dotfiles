final: prev:

{
  alacritty = final.callPackage ./packages/alacritty.nix { alacritty = prev.alacritty; };

  neovim-unwrapped = final.callPackage ./packages/neovim-unwrapped.nix {
    neovim-unwrapped = prev.neovim-unwrapped;
  };

  vimPlugins = final.callPackage ./packages/vim-plugins.nix {
    vimPlugins = prev.vimPlugins;
  };

  neovim-package = final.callPackage ./packages/neovim-package { };

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

  # not a package per se, this is only necessary to generate plugins-sources.json
  # (required for install-manual.sh)
  plugins-sources = import ./packages/plugins-sources.nix {
    inherit (final) neovim-package zsh-autosuggestions zsh-syntax-highlighting;
  };
}
