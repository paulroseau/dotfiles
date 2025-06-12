{ lib
, neovim
, blinkCmpFuzzy
, treeSitterParsers
, sources
, stdenv
}:

with lib;

let
  neovimPlugin =
    { pname
    , src
    , namePrefix ? "neovim-plugin-"
    , meta ? {}
    , readme ? "README.md"
  }:
    stdenv.mkDerivation {
      name = namePrefix + "${pname}";
      inherit pname src readme;

      phases = [ "unpackPhase" "buildPhase" "installPhase" ];

      nativeBuildInputs = [ neovim ];

      buildPhase = ''
        if [ -d "./doc" ]; then
          nvim --headless -u NONE -i NONE -n -c "helptags ./doc" -c "quit"
        elif [ -f "./$readme" ]; then
          echo "No docs available for $pname, using $readme"
          # Force filetype to markdown since nvim sets filetype=help when opening a file through :help
          echo '<!-- vim: set ft=markdown: -->' >> ./$readme
          mkdir -p ./doc
          cp ./$readme ./doc/
          echo -e "${pname}.$readme\t$readme\t/# " >> ./doc/tags
        else
          echo "No docs available for $pname"
        fi

        runHook postBuild
      '';

      installPhase = ''
        mkdir $out
        cp -r ./ $out/${pname}
      '';

      meta = {
        platforms = lib.platforms.all;
        isNeovimPlugin = true;
      } // meta;
    };

  basePlugins = self: builtins.mapAttrs (pname: src:
    neovimPlugin {
      inherit pname src;
    }
  ) sources;

  overridePlugins = self: super: 
    {
      nvim-treesitter = super.nvim-treesitter.overrideAttrs {
        postBuild = ''
          target="./parser"
          if [ -d $target ]; then
            rm -r $target
          fi
          ln -s ${treeSitterParsers} $target
        '';
      };

      blink-cmp = super.blink-cmp.overrideAttrs {
        postBuild = ''
          target="./target/release"
          mkdir -p $target
          ln -s ${blinkCmpFuzzy}/lib/* $target
        '';
      };
    };
in
  fix (extends overridePlugins basePlugins)
