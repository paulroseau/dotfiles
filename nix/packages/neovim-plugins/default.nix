{ lib
, stdenv
, buildEnv
, neovim-unwrapped
, tree-sitter
, linkFarm
, neovimPluginsSources
, treeSitterParsersSources
}:

let
  treeSitterParsers = import ./tree-sitter-parsers {
    inherit lib tree-sitter linkFarm;
    sources = treeSitterParsersSources;
    neovimVersion = neovim-unwrapped.version;
  };

  neovimPlugins =
    let 
      plugins = import ./plugins {
        inherit lib stdenv treeSitterParsers;
        neovim = neovim-unwrapped;
        sources = neovimPluginsSources;
      };

    in
      buildEnv {
        name = "neovim-plugins";
        extraPrefix = "/share/neovim-plugins";
        paths = lib.attrsets.attrValues plugins;
      };

in neovimPlugins
