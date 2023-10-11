{ lib
, buildEnv
, runCommand
, runtimeShell
, alacritty
, glibc
, mesa
, nerdfonts
, fetchFromGitHub
}:

let
  selectedNerdFonts = nerdfonts.override {
    fonts = [ "Agave" "Hack" "Hermit" "Terminus" ];
  };

  alacrittyTheme =
    let
      pname = "alacritty-theme";
    in
      runCommand pname {
        src = fetchFromGitHub {
          owner = "alacritty";
          repo = pname;
          rev = "master";
          hash = "sha256-3BkRl7vqErQJgjqkot1MFRb5QzW4Jtv1Fuk4+CQfZOs=";
        };
      }
      ''
      mkdir -p $out/share
      cp -r $src/themes $out/share/alacritty-themes
      '';

  # Modify the alacritty derivation itself adding a postInstall hook rather
  # than creating a standalone derivation with writeScriptBin because we also
  # need what is in $out/share in the alacritty derivation (icon, shell
  # completions, etc.)

  # We are not using LD_LIBRARY_PATH environment variable as in nixGL since
  # environment variables are inherited by any child processes (ie. all the
  # processes launched from alacritty terminal: shells, etc.). We instead run
  # the dynamic linker directly and append the mesa drivers path to the search
  # path (cf. man ld)
  # Reminder we cannot use patchelf on alacritty because the RUNPATH is okay
  # there. It is the RUNPATH of one of its dependencies, libglvnd, which would
  # need to be patched. For details why we don't patch libglvnd check the notes.
  # Credits to: https://gms.tf/ld_library_path-considered-harmful.html

  wrappedAlacritty = alacritty.overrideAttrs(_: _: {
    postInstallHooks = [
      ''
        mv $out/bin/alacritty $out/bin/_alacritty
        cat >$out/bin/alacritty <<EOF
        #!${runtimeShell}
        export LIBGL_DRIVERS_PATH=${lib.makeSearchPathOutput "drivers" "lib/dri" [mesa]}
        exec ${lib.makeBinPath [glibc.bin]}/ld.so --library-path ${lib.makeLibraryPath [mesa.drivers]} $out/bin/_alacritty
        EOF
        chmod +x $out/bin/alacritty
      ''
    ];
  });

in
  buildEnv {
    name = "alacritty-packages";
    pathsToLink = ["/" "/share"];
    paths = [
      wrappedAlacritty
      alacrittyTheme
      selectedNerdFonts
    ];
  }
