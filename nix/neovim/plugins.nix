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

  overridePlugins = self: super: 
    let 
      nvimCmpSourcePlugin = plugin: plugin.overrideAttrs {
        dependencies = [ self.nvim-cmp ];
      };
    in {
      lualine-nvim = super.lualine-nvim.overrideAttrs {
        dependencies = [
          self.nvim-web-devicons
        ];
      };

      cmp-buffer = nvimCmpSourcePlugin super.cmp-buffer;

      cmp-nvim-lsp = nvimCmpSourcePlugin super.cmp-nvim-lsp;

      cmp-nvim-lsp-signature-help = nvimCmpSourcePlugin super.cmp-nvim-lsp-signature-help;

      cmp-nvim-lua = nvimCmpSourcePlugin super.cmp-nvim-lua;

      cmp-path = nvimCmpSourcePlugin super.cmp-path;

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

      fzf-lua = super.fzf-lua.overrideAttrs {
        dependencies = [
          self.nvim-web-devicons
        ];
      };
    };

in
  fix (extends overridePlugins basePlugins)
