{ lib
, stdenv
, buildEnv
, neovim-unwrapped
, fetchFromGitHub
, tree-sitter
, linkFarm
}:

let
  # Need to use nightly after fix for https://github.com/neovim/neovim/issues/22041
  neovim = (
    neovim-unwrapped.override { inherit tree-sitter; }
  ).overrideAttrs (self: super: {
    version = "nightly";

    src = super.src.override {
      rev = self.version;
      hash = "sha256-2JHBvDWMKd3brUwzU5NMc2cqrrqyoXZ3p8AFN82MNPI=";
    };
  });

  utils = import ./utils.nix {
    inherit lib stdenv buildEnv neovim;
  };

  treeSitterExtraParsers = import ./tree-sitter-parsers.nix {
    inherit lib fetchFromGitHub tree-sitter linkFarm;
    neovimVersion = neovim.version;
  };

  allPlugins = import ./plugins.nix {
    inherit lib fetchFromGitHub;
    buildNeovimPlugin = utils.buildNeovimPlugin;
    neovimExtraTreesitterParsers = treeSitterExtraParsers;
  };

  myNeovimPlugins = utils.bundleNeovimPlugins {
    name = "my-neovim-plugins";
    extraPrefix = "/share/neovim-plugins";
    plugins = with allPlugins; [
      comment-nvim
      fzf-lua
      lualine-nvim
      neo-tree-nvim
      nvim-surround
      nvim-treesitter
    ];
  };

in
  buildEnv {
    name = "neovim-packages";
    paths = [
      neovim
      myNeovimPlugins
    ];
  }
