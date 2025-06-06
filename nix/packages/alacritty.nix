{ lib
, stdenv
, runtimeShell
, alacritty
, glibc
, mesa
}:

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

alacritty.overrideAttrs(_: _: {
  postInstallHooks = 
    if stdenv.hostPlatform.isLinux 
    then [
      ''
        mv $out/bin/alacritty $out/bin/_alacritty
        cat >$out/bin/alacritty <<EOF
        #!${runtimeShell}
        export LIBGL_DRIVERS_PATH=${lib.makeSearchPathOutput "drivers" "lib/dri" [mesa]}
        exec ${lib.makeBinPath [glibc.bin]}/ld.so --library-path ${lib.makeLibraryPath [mesa.drivers]} $out/bin/_alacritty \$@
        EOF
        chmod +x $out/bin/alacritty
      ''
    ]
    else [] ;
})
