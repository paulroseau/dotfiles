{ buildEnv
, fzf
, starship
, zsh
, zsh-z
, zsh-autosuggestions
, zsh-syntax-highlighting
}:

let
  # TODO: remove when the nixpkgs version has caught up
  updatedZshZ = 
    zsh-z.overrideAttrs (self: super: {
      version = "unstable-2023-06-14";

      src = super.src.override {
        rev = "dc9e2bc0cdbaa0a507371c248d3dcc9f58db8726";
        sha256 = "03dgdblgw6i0jc7h15r2qhfcmjbrn14xk7lyd54lrv6vshmrjj2g";
      };
    });

  zshPlugins = [
    zsh-autosuggestions
    zsh-syntax-highlighting
    updatedZshZ
  ];

in
  buildEnv {
    name = "zsh-packages";
    paths = [
      zsh
      starship
      fzf
    ] ++ zshPlugins;
  }
