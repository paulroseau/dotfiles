{ buildEnv
, starship
, zsh
, zsh-autosuggestions
, zsh-syntax-highlighting
}:

let
  zshPlugins = [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

in
  buildEnv {
    name = "zsh-packages";
    paths = [
      zsh
      starship
    ] ++ zshPlugins;
  }
