{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
  writeShellApplication,
  static-web-server,
}:

let
  excalidraw-static = stdenv.mkDerivation (finalAttrs: {
    pname = "excalidraw-static";
    version = "0.18.0";

    src = fetchFromGitHub {
      owner = "excalidraw";
      repo = "excalidraw";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Nfzh5rNvHP7R418PP44FXD7xNenzmzMHu7RLAdJsE/c=";
    };

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = "sha256-R3O/nHSp7gUC4tNAq7HoIY+k/5kgx5gew2uFOPAPWW8=";
    };

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs
    ];

    yarnBuildScript = "build:app:docker";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -r ./excalidraw-app/build $out/share/excalidraw-static

      runHook postInstall
    '';

    meta = {
      description = "Static build of Excalidraw (web app) via Nix";
      homepage = "https://github.com/excalidraw/excalidraw";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  });

  excalidraw-serve = writeShellApplication {
    name = "excalidraw";
    runtimeInputs = [ static-web-server ];
    text = ''
      exec static-web-server \
        --root "''${EXCALIDRAW_ROOT:-${excalidraw-static}/share/excalidraw-static}" \
        "$@"
    '';
  };

in
excalidraw-serve
