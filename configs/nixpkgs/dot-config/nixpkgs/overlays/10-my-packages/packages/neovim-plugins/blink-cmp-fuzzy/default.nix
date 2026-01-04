{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
}:

let
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${version}";
    hash = "sha256-JjlcPj7v9J+v1SDBYIub6jFEslLhZGHmsipV1atUAFo=";
  };

  blink-fuzzy-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "blink-fuzzy-lib";

    useFetchCargoVendor = true;
    cargoHash = "sha256-Qdt8O7IGj2HySb1jxsv3m33ZxJg96Ckw26oTEEyQjfs=";

    nativeBuildInputs = [ gitMinimal ];

    env = {
      # TODO: remove this if plugin stops using nightly rust
      RUSTC_BOOTSTRAP = true;
    };
  };

in
blink-fuzzy-lib
