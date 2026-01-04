{
  linkFarm,
  nvimTreeSitterPlugin,
  languages,
}:

let
  name = "stripped-nvim-treesitter";

  queryEntry = {
    name = "queries";
    path = "${nvimTreeSitterPlugin}/runtime/queries";
  };

  pluginFiletypesEntry = {
    name = "plugin/filetypes.lua";
    path = "${nvimTreeSitterPlugin}/plugin/filetypes.lua";
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
linkFarm name (
  [
    queryEntry
    pluginFiletypesEntry
  ]
  ++ parserEntries
)
