{ lib
, linkFarm
, tree-sitter
, neovimVersion
, sources
}:

with lib;

let
  args = let
    base = self: builtins.mapAttrs (name: src: {
      inherit src;
      language = name;
      version = "neovim-${neovimVersion}";
    }) sources;

    override = self: super: {
      markdown = super.markdown // { location = "tree-sitter-markdown"; };
      markdown_inline = super.markdown // { language = "markdown_inline"; location = "tree-sitter-markdown-inline"; };
      ocaml = super.ocaml // { location = "ocaml"; };
      ocaml_interface = super.ocaml // { location = "interface"; };
    };
  in
    fix (extends override base);

  buildGrammar = tree-sitter.buildGrammar.override { inherit tree-sitter; };

  build = name: args: {
    name = "${name}.so";
    path = "${buildGrammar args}/parser";
  };

  parsers = mapAttrsToList build args;

in
  linkFarm "nvim-treesitter-extra-parsers" parsers
