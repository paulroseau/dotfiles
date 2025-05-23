{ lib
, buildEnv
, fetchFromGitHub
, gitMinimal
, linkFarm
, neovim-unwrapped
, neovimPluginsSources
, rustPlatform
, stdenv
, tree-sitter
, treeSitterParsersSources
}:

let
  treeSitterParsers = import ./tree-sitter-parsers {
    inherit lib tree-sitter linkFarm;
    sources = treeSitterParsersSources;
    neovimVersion = neovim-unwrapped.version;
  };

  blinkCmpFuzzy = import ./blink-cmp-fuzzy {
    inherit fetchFromGitHub gitMinimal rustPlatform;
  };

  neovimPlugins =
    let 
      plugins = import ./plugins {
        inherit lib stdenv treeSitterParsers blinkCmpFuzzy;
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
