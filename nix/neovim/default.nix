{ lib
, stdenv
, buildEnv
, neovim-unwrapped
, tree-sitter
, linkFarm
, sources
}:

let
  neovim = (
    neovim-unwrapped.override { inherit tree-sitter; }
  ).overrideAttrs (self: super: {
    version = sources.neovim.rev;
    src = sources.neovim;
  });

  treeSitterParsers = import ./tree-sitter-parsers {
    inherit lib tree-sitter linkFarm;
    sources = sources.treeSitterParsers;
    neovimVersion = neovim.version;
  };

  neovimPlugins =
    let 
      plugins = import ./plugins {
        inherit lib stdenv neovim treeSitterParsers;
        sources = sources.neovimPlugins;
      };

    in
      buildEnv {
        name = "neovim-plugins";
        extraPrefix = "/share/neovim-plugins";
        paths = lib.attrsets.attrValues plugins;
      };

in
  [
    neovim
    neovimPlugins
  ]
