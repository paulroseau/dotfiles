{
  fetchFromGitHub,
  neovim-unwrapped,
}:

neovim-unwrapped.overrideAttrs (
  final: prev: {
    version = "0.11.5";
    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      tag = "v${final.version}";
      hash = "sha256-OsvLB9kynCbQ8PDQ2VQ+L56iy7pZ0ZP69J2cEG8Ad8A=";
    };
  }
)
