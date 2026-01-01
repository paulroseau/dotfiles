{
  lib,
  fetchFromGitHub,
  linkFarm,
  vimPlugins,
}:

let
  name = "neovim-plugins";

  prefix = "share/nvim/site/pack/nix-managed-plugins";

  nvimTreeSitterPlugin = vimPlugins.nvim-treesitter.overrideAttrs (oldAttrs: rec {
    name = "${oldAttrs.pname}-${version}";
    version = "unstable-2026-01-01";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "c6dd314086f7b471bf6c9110092a94ce1c06d220";
      hash = "sha256-7HJ0gEFHFzsAGVpZzBxjEKuwuG4zID9eP3GLQdhZAl4=";
    };
    postPatch = ":";
    doCheck = false;
  });

  nvimTreeSitterGrammars = import ./nvim-treesitter-grammars.nix {
    inherit linkFarm nvimTreeSitterPlugin;

    languages = [
      "bash"
      "c"
      "dockerfile"
      "go"
      "haskell"
      "hcl"
      "json"
      "lua"
      "markdown"
      "markdown_inline"
      "nix"
      "ocaml"
      "ocaml_interface"
      "python"
      "query"
      "rust"
      "scala"
      "vim"
      "vimdoc"
      "yaml"
      "zsh"
    ];
  };

  requiredPlugins = [
    vimPlugins.blink-cmp
    vimPlugins.codecompanion-nvim
    vimPlugins.comment-nvim
    vimPlugins.flatten-nvim
    vimPlugins.friendly-snippets
    vimPlugins.fzf-lua
    vimPlugins.lazydev-nvim
    vimPlugins.lualine-nvim
    vimPlugins.mini-pairs
    vimPlugins.neo-tree-nvim
    vimPlugins.nord-nvim
    vimPlugins.nui-nvim
    vimPlugins.nvim-surround
    vimPlugins.nvim-web-devicons
    vimPlugins.onedarkpro-nvim
    vimPlugins.plenary-nvim
    vimPlugins.rustaceanvim
    vimPlugins.toggleterm-nvim
    vimPlugins.tokyonight-nvim
    vimPlugins.vim-fugitive
    vimPlugins.zen-mode-nvim
    nvimTreeSitterPlugin
  ];

  vimFarm =
    prefix: name: drvs:
    let
      entryToDrv = drv: {
        name = "${prefix}/start/${lib.getName drv}";
        path = drv;
      };
    in
    linkFarm name (map entryToDrv drvs);
in

vimFarm prefix name (requiredPlugins ++ [ nvimTreeSitterGrammars ])
