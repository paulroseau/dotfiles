let overlayFn = self: super: import ./overlay.nix self super;
in import <nixpkgs> { overlays = [ overlayFn ]; }
