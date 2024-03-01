let
  sources = import ./sources.nix {};

  nixpkgs = import sources.nixpkgs {};

  neovimPluginsSources = import ./sources.nix { 
    pkgs = nixpkgs;
    sourcesFile = ./neovim/plugins/sources.json ;
  };

  treeSitterParsersSources = import ./sources.nix {
    pkgs = nixpkgs;
    sourcesFile = ./neovim/tree-sitter-parsers/sources.json ;
  };

  pkgs = import ./main.nix {
    pkgs = nixpkgs;
    sources = sources // {
      neovimPlugins = neovimPluginsSources;
      treeSitterParsers = treeSitterParsersSources;
    };
  };

in
  pkgs
