{ lib
, stdenv
, buildEnv
, neovim-unwrapped
, fetchFromGitHub
, tree-sitter
, linkFarm
}:

let
  neovim = (
    neovim-unwrapped.override { inherit tree-sitter; }
  ).overrideAttrs (self: super: {
    version = "v0.9.5";

    src = super.src.override {
      rev = self.version;
      hash = "sha256-CcaBqA0yFCffNPmXOJTo8c9v1jrEBiqAl8CG5Dj5YxE=";
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
      cmp-buffer
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-nvim-lua
      cmp-path
      comment-nvim
      flatten-nvim
      fzf-lua
      lualine-nvim
      neo-tree-nvim
      nvim-lspconfig
      nvim-surround
      nvim-treesitter
      onedark-nvim
      toggleterm-nvim
      tokyonight-nvim
      vim-fugitive
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
