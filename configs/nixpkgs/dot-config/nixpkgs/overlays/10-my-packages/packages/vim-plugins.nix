{
  fetchFromGitHub,
  vimUtils,
  vimPlugins,
}:

vimPlugins
// {
  # TODO remove this once:
  # 1. nvim-treesitter has released a stable version off the new `main` branch
  # 2. the runtime/queries/vim/highlight.scm no longer includes "tab" or the latest treesitter vim parser.so supports it

  # Currently nixpkgs points to v0.10.0 from May 2025 which is based off the
  # locked `master` branch. `nvim-treesitter` is moving towards a more
  # lightweight version that just deals with installing and updating parsers as
  # well as packaging built-in queries for neovim

  # We install parsers through nix so we don't need nvim-treesitter's core
  # functionality. However the nixpkgs's vimPlugins.nvim-treesitter already
  # includes parsers built off the versions specified in
  # `nvim-treesitter/parsers.lua`. We will reuse those to build a stripped down
  # plugin which does NOT manage the the parsers.

  # NB: in practice this information is uploaded as a json file to
  # https://raw.githubusercontent.com/nvim-neorocks/nurr/main/tree-sitter-parsers.json
  # the which `vim/plugins/utils/nvim-treesitter/update.py` reads to generate
  # the parsers derivation in nixpkgs) so pinning the version below is just
  # relevant for the queries bundled in nvim-treesitter (the parsers follow
  # `main` no matter what since
  # https://raw.githubusercontent.com/nvim-neorocks/nurr/main/tree-sitter-parsers.json
  # is automatically updated every day)
  nvim-treesitter = vimPlugins.nvim-treesitter.overrideAttrs (
    final: prev: {
      name = "${final.pname}-${final.version}";
      version = "unstable-2025-12-20";
      src = fetchFromGitHub {
        owner = "nvim-treesitter";
        repo = "nvim-treesitter";
        rev = "f795520371e6563dac17a0d556f41d70ca86a789"; # bug inserted in queries/vim/highlight.scm right after this commit (adds "tab" support)
        hash = "sha256-b98BfpfHzrwHYBhC2nnQrUK8n/7OdAnevV0zg1Dyb+c=";
      };
      postPatch = ":";
      doCheck = false;
    }
  );

  gitmoji-nvim = vimUtils.buildVimPlugin {
    pname = "gitmoji.nvim";
    version = "unstable-2025-04-23";
    src = fetchFromGitHub {
      owner = "Dynge";
      repo = "gitmoji.nvim";
      rev = "2659de229c2b26d50732f1220700eebbcdb2d6ef";
      hash = "sha256-cihJ2U+GIqf98t6wS4Fso6R8l69vXT+BsstqY7rrlc4=";
    };
    meta.homepage = "https://github.com/Dynge/gitmoji.nvim";
  };

  solarized-nvim = vimUtils.buildVimPlugin {
    pname = "solarized.nvim";
    version = "3.6.0";
    src = fetchFromGitHub {
      owner = "maxmx03";
      repo = "solarized.nvim";
      rev = "c0dfe1cbfabd93b546baf5f1408f5df7e02e2050";
      hash = "sha256-fNytlDlYHqX1W1pqt8xLoud+AtMQDlmtUkbwZArj4bs=";
    };
    meta.homepage = "https://github.com/maxmx03/solarized.nvim";
  };

  wildfire-nvim = vimUtils.buildVimPlugin {
    pname = "wildfire.nvim";
    version = "unstable-2025-10-14";
    src = fetchFromGitHub {
      owner = "SUSTech-data";
      repo = "wildfire.nvim";
      rev = "918a1873c2b8010baa034f373cf28c53ce4f038f";
      hash = "sha256-HGNBUuUFtZU9ozFsM0X5QadfnK+cEiosQfnnrI6bdtI=";
    };
    meta.homepage = "https://github.com/SUSTech-data/wildfire.nvim";
  };
}
