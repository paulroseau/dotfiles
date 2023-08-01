{ lib
, fetchFromGitHub
, buildNeovimPlugin
, neovimExtraTreesitterParsers
}:

with lib;

let
  sourceArgs = builtins.fromJSON (
    builtins.readFile ./plugins-source.json
  );

  f = pname: {
    name = pname;
    value = buildNeovimPlugin {
      inherit pname;
      src = fetchFromGitHub (builtins.getAttr pname sourceArgs);
    };
  };

  pluginList = [
    "lualine-nvim"
    "nvim-web-devicons"
    "nvim-treesitter"
    "neo-tree-nvim"
    "nui-nvim"
    "plenary-nvim"
  ];

  basePlugins = self: builtins.listToAttrs (builtins.map f pluginList);

  overridePlugins = self: super: {
    lualine-nvim = super.lualine-nvim.overrideAttrs {
      dependencies = [
        self.nvim-web-devicons
      ];
    };

    nvim-treesitter = super.nvim-treesitter.overrideAttrs {
      postInstall = ''
        target="$out/$pname/parser"
        if [ -d $target ]; then
          rm -r $target
        fi
        ln -s ${neovimExtraTreesitterParsers} $target
      '';
    };

    neo-tree-nvim = super.neo-tree-nvim.overrideAttrs {
      dependencies = [
        self.nui-nvim
        self.nvim-web-devicons
        self.plenary-nvim
      ];
    };
  };

in
  fix (extends overridePlugins basePlugins)
