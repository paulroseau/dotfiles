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

  basePlugins = self: builtins.mapAttrs (name: srcArg:
    buildNeovimPlugin {
      pname = name;
      src = fetchFromGitHub srcArg;
    }
  ) sourceArgs;

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

    telescope-nvim = super.telescope-nvim.overrideAttrs {
      dependencies = [
        self.nvim-treesitter
        self.nvim-web-devicons
        self.plenary-nvim
      ];
    };
  };

in
  fix (extends overridePlugins basePlugins)
