{
  neovim-package,
  zsh-autosuggestions,
  zsh-syntax-highlighting,
}:

let
  buildSourceInfo =
    drvs:
    let
      drvSourceInfo = drv: {
        name = drv.pname;
        value = {
          rev = drv.src.rev or null;
          owner = drv.src.owner or null;
          repo = drv.src.repo or null;
        };
      };

    in
    builtins.listToAttrs (map drvSourceInfo drvs);

in
{
  neovim = buildSourceInfo neovim-package.repos;
  zsh = buildSourceInfo [
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
}
