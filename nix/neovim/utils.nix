{ lib
, stdenv
, buildEnv
, neovim
}:

{
  buildNeovimPlugin =
    { pname
    , src
    , namePrefix ? "neovim-plugin-"
    , meta ? {}
    , dependencies ? []
    , readme ? "README.md"
  }:
    stdenv.mkDerivation {
      name = namePrefix + "${pname}";
      inherit pname src dependencies;

      phases = [ "installPhase" "fixupPhase" ];

      nativeBuildInputs = [ neovim ];

      installPhase = ''
        mkdir $out
        cp -r $src $out/${pname}
        chmod +w -R $out/${pname}

        runHook postInstall
      '';

      fixupPhase = ''
        target=$out/${pname}
        if [ -d "$target/doc" ]; then
          echo "Building help tags"
          if ! nvim -u NONE -i NONE -n -c "helptags $target/doc" -c "quit"; then
            echo "Failed to build help tags!"
            exit 1
          fi
        elif [ -f "$target/${readme}" ]; then
          echo "No docs available for $target, using ${readme}"
          mkdir -p $target/doc
          # Force filetype to markdown since nvim sets filetype=help when opening a file through :help
          echo '<!-- vim: set ft=markdown: -->' >> $target/${readme}
          cp $target/${readme} $target/doc/
          echo -e "${pname}.${readme}\t${readme}\t/# " >> $target/doc/tags
        else
          echo "No docs available for $target"
        fi
      '';

      meta = {
        platforms = lib.platforms.all;
        isNeovimPlugin = true;
      } // meta;
    };

  bundleNeovimPlugins =
    { name
    , extraPrefix
    , plugins
    }:
    let 
      findDependenciesRecursively = ps: accum:
        if ps == [] then accum 
        else
          let 
            newAccum = lib.unique (ps ++ accum);
            allDirectDependencies = lib.unique (
              builtins.concatMap (p: p.dependencies or []) ps
            );
            unexploredPlugins = lib.subtractLists newAccum allDirectDependencies;
          in
            findDependenciesRecursively unexploredPlugins newAccum;
    in
      buildEnv {
        inherit name extraPrefix;
        paths = findDependenciesRecursively plugins [];
      };
}
