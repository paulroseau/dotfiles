{
  linkFarm,
  nvimTreeSitterPlugin,
  languages,
}:

let
  name = "nvim-treesitter-grammars";

  queryEntry = {
    name = "queries";
    path = "${nvimTreeSitterPlugin}/runtime/queries";
  };

  parserEntries = builtins.map (
    language:
    let
      drv = nvimTreeSitterPlugin.builtGrammars.${language};
    in
    {
      name = "parser/${language}.so";
      path = "${drv}/parser";
    }
  ) languages;

in
linkFarm name ([ queryEntry ] ++ parserEntries)
