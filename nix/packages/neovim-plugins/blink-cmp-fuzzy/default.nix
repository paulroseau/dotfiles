{
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
}:

let
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.cmp";
    tag = "v${version}";
    hash = "sha256-eMUOjG2CtedCGVU1Pdp8PCCgGoFbjeVvK7lMS8E+ogg=";
  };

  blink-fuzzy-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "blink-fuzzy-lib";

    useFetchCargoVendor = true;
    cargoHash = "sha256-zWZHT+Y8ENN/nFEtJnkEUHXRuU6FUQ/ITHo+V4zJ6f8=";

    nativeBuildInputs = [ gitMinimal ];

    env = {
      # TODO: remove this if plugin stops using nightly rust
      RUSTC_BOOTSTRAP = true;
    };
  };

in
blink-fuzzy-lib
