{
  fetchFromGitHub,
  neovim-unwrapped,
}:

neovim-unwrapped.overrideAttrs (
  final: prev: {
    version = "0.11.6";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      tag = "v${final.version}";
      hash = "sha256-GdfCaKNe/qPaUV2NJPXY+ATnQNWnyFTFnkOYDyLhTNg=";
    };
  }
)
