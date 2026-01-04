{
  lib,
  linkFarm,
  vimPlugins,
}:

let
  name = "neovim-plugins";

  prefix = "share/nvim/site/pack/nix-managed-plugins";

  # We override vimPlugins.nvim-treesitter by a simpler derivation which just includes:
  # - nvim-treesitter/runtime/queries
  # - nvim-treesitter/plugin/filetypes (necessary to interpret `sh` as `bash` for instance)
  # - a set of parsers of interest which versions always follow nvim-treesitter's main branch since nixpkgs pulls them from https://raw.githubusercontent.com/nvim-neorocks/nurr/main/tree-sitter-parsers.json

  # NB: there is a slight risk that the queries diverge from the parsers if you the nvim-treesitter's version is pinned to a too old version in your vimPlugin overlay. This is a problem nixpkgs currently has since nvim-treesitter points to master which is much older than main from which the parsers' version file is generated on https://raw.githubusercontent.com/nvim-neorocks/nurr/main/tree-sitter-parsers.json
  stripped-nvim-treesitter-plugin = import ./stripped-nvim-treesitter-plugin.nix {
    inherit linkFarm;

    nvimTreeSitterPlugin = vimPlugins.nvim-treesitter;

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

  fromNixpkgsPlugins = [
    vimPlugins.blink-cmp
    vimPlugins.codecompanion-nvim
    vimPlugins.comment-nvim
    vimPlugins.catppuccin-nvim
    vimPlugins.flatten-nvim
    vimPlugins.friendly-snippets
    vimPlugins.fzf-lua
    vimPlugins.gitmoji-nvim
    vimPlugins.lazydev-nvim
    vimPlugins.lualine-nvim
    vimPlugins.mini-pairs
    vimPlugins.neo-tree-nvim
    vimPlugins.nord-nvim
    vimPlugins.nui-nvim
    vimPlugins.nvim-surround
    vimPlugins.nvim-web-devicons
    vimPlugins.nightfox-nvim
    vimPlugins.onedarkpro-nvim
    vimPlugins.plenary-nvim
    vimPlugins.rustaceanvim
    vimPlugins.solarized-nvim
    vimPlugins.toggleterm-nvim
    vimPlugins.tokyonight-nvim
    vimPlugins.vim-fugitive
    vimPlugins.zen-mode-nvim
  ];

  requiredPlugins = [
    stripped-nvim-treesitter-plugin
  ]
  ++ fromNixpkgsPlugins;

  repos = [ vimPlugins.nvim-treesitter ] ++ fromNixpkgsPlugins;

  neovimPackage =
    let
      entryToDrv = drv: {
        name = "${prefix}/start/${lib.getName drv}";
        path = drv;
      };
    in
    linkFarm name (map entryToDrv requiredPlugins);
in

neovimPackage.overrideAttrs (
  _: prev: {
    passthru = (prev.passthru or { }) // {
      # to generate neovim-plugin-sources.json file for manual install
      repos = repos;
    };
  }
)
