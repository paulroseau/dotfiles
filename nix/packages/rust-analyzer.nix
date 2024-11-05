{ rust-analyzer
, runCommand
, rustPlatform
, cacert
, cargo
}:

# rust-analyzer tries to generate the Cargo.lock file for a project when it
# is missing. Since the standard library source code does not contain any
# Cargo.lock files, rust-analyzer crashes because it does not have write
# permissions on /nix/store/...-rustLibSrc (the nix store is read-only!)
#
# Here we create a copy of the rustSrc derivation and override this
# parameter when deriving rust-analyzer. We don't just overlay on
# rustPlatform.rustLibSrc because that causes nix to rebuild every rust
# package rather than pulling those from the cache
rust-analyzer.override {
  rustSrc = runCommand "rust-lib-src-with-cargo-lock" {
     # necessary to make this a fixed output derivation so the build can run
     # outside of the sandbox since Cargo needs to fetch dependencies over
     # the network
     outputHashMode = "recursive";
     outputHashAlgo = "sha256";
     outputHash = "sha256-45LK98UrBfn2PEAEd3vhTKpkFQgw/lQKe0l2D6xXJHI="; 
   } ''
     mkdir $out
     cp -r ${rustPlatform.rustLibSrc}/* $out/
     chmod -R u+w $out/

     # necessary so cargo can validate the SSL certs from crates.io
     export CARGO_HTTP_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt

     # necessary for cargo to find crates included in the directory tree
     cd $out

     find . -name 'Cargo.toml' -exec ${cargo}/bin/cargo generate-lockfile --manifest-path {} \;
   '';
}
