# Mesa drivers

- Source:
  - nixpkgs source code
  - https://github.com/NixOS/nixpkgs/issues/9415
  - https://github.com/NixOS/nixpkgs/issues/62169
  - https://docs.mesa3d.org/envvars.html
  - https://en.wikipedia.org/wiki/Rpath

- On Linux, alacritty depends on `libGL` which depends on `libglvnd`.
  `libglvnd` is a wrapper around functionalities implemented in driver libraries.
  However like any nix artifacts, libglvnd `RUNPATH` is hardcoded to nix store
  libraries AND to `/run/opengl-driver` which is added thanks to the
  `addOpenglRunpath` hook which is part of the `libglvnd.postFixUp`
  To launch `alacritty` as is, you have 2 options:
  - Option 1:
    ```sh
    LD_LIBRARY_PATH=/lib alacritty
    ```
    which is not recommended since all libraries pulled by alacritty will be
    searched in priority in `/lib` instead of the hardcoded nix store libs in each
    nix binary `RUNPATH`
    (cf. readelf -d `which alacritty`)
  - Option 2:
    ```sh
    sudo mkdir -p /run/opengl-driver
    sudo ln -s $HOME/.nix-profile/lib /run/opengl-driver
    ```
    which will allow `libglvnd` to find the drivers built by nix from mesa.drivers
    at runtime.
    However `/run` uses a tmpfs filesystem, so this will need to be run with sudo
    each time on boot

- I tried 2 approaches to circumvent this issue.
  - Approach 1:
    Create overlays which would inject the path to the mesa drivers directly.
    ```nix
      pkgs =
        let
          overlays = [
            (self: super:
            {
              addOpenGLRunpath = super.addOpenGLRunpath.overrideAttrs(_: _: {
                driverLink = "${super.mesa.drivers}";
              });
            })
          ];
        in
          nixPkgsFunction { inherit overlays;  };
    ```
    However this does not work because `mesa` depends on `libglvnd` which depends on
    `addOpenGLRunpath`. It seems to me this dependency is there only to grab
    `libglvnd.driverLink` (which is pulled from `addOpenGLRunpath.driverLink`) but
    since `libglvnd` is in mesa  `buildInputs`, it needs to be evaluated first
    when building mesa and hence creating a circular dependency since the path
    `${mesa.drivers}` is computed after all inputs to `mesa` have been evaluated.
    We could have tried to create 2 overlays, but it seemed too risky to me
    considering that I am not sure why `libglvnd` is in the `buildInputs`. From my
    understanding, it just will cause it to be built and its binaries to be put in the `PATH` automatically (cf.
    `stdenv/setup.sh`) but it has no binaries. It does not seem to me that `./lib` of
    `buildInputs` are automatically added to the `RPATH` (this looks manual, for instance for
    alacritty the `RPATH` is patched in `alacritty.postInstall`) so it should be fine to strip it, but then we also have to
    update `mesa.postfixup` and `mesa.mesonFlags` which ends up being ugly
    ```nix
      pkgs =
        let
          overlays = [
            (self: super:
            {
              addOpenGLRunpath = super.addOpenGLRunpath.overrideAttrs(_: _: {
                driverLink = "${super.mesa.drivers}";
              });
            })
            (self: super:
            {
              mesa = super.mesa.overrideAttrs(selfMesa: superMesa: {
                postFixup = # grep selfMesa.postFixup
                buildInput = # remove libglvnd
                mesonFlags = # update some flags or hardcode
              });
            })
          ];
        in
          nixPkgsFunction { inherit overlays;  };
    ```
  - Approach 1bis:
    We could manually `patchelf` libglvnd, but since libglvnd has many libs, this would require modify all of them, while we are not sure they are all used, which seems a bit ugly as well.
  - Approach 2:
    Inspired by https://github.com/guibou/nixGL, create a wrapper script which
    sets `LD_LIBRARY_PATH` to the exact paths that needs to be included before running
    `alacritty`. We just add a hook thanks to postInstallHooks which expects a
    list (cf. `stdenv/setup.sh` `runHook` function, `hooksSlice` variable)
  - Approach 2bis:
    Wrap alacritty in a script which launches alacritty with `ld.so --library-path <path>` rather than setting the environment variable. Indeed when forking processes all environment variable from the parent are inherited by the child, which means in the case of alacritty that any process launched through it (shell, etc.) will look for its libraries inside the drivers folder first.
    Reminder we cannot use patchelf on alacritty because the RUNPATH is okay there. It is the RUNPATH of one of its dependencies, libglvnd, which would need to be patched
