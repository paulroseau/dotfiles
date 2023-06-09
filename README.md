# My dotfiles

## Install

```
./install.sh
```

## TODO

- Theorie
  - revoir les LD_FLAGS et le cc wrapper (cf. `_addToRpath` in `setup.sh`)
  - hooks (addEnvHooks addToEnv)
  - revoir les bases de la compilation et du linking: https://stackoverflow.com/questions/6562403/i-dont-understand-wl-rpath-wl?rq=3

- Alacritty
  - [x] trouver palette jolie: installer la palette avec nix, https://github.com/alacritty/alacritty-theme/blob/master/themes/tokyo-night-storm.yaml, voir si tu fais un lien vers la palette dans .nix-profile, ou si tu bundle tout dans ton alacritty -> plutt la première option
  - [x] installer alacritty comme une app pour que tu puisses la trouver dans la barre de recherche (voir comment ca marcherait sur Mac)
  - [x] faire un environnement separe pour alacritty
  - settuper alacritty sans avoir à faire de step manuel `sudo ln /run/opengl-driver`, options :
    - [ ] option 1: patcher `libglvnd` pour qu'au lieu de faire addOpenGL path, on mette le path vers mesa driver
        - il y a une dependence mesa -> liblgnvd -> addOpenGL, il faut la casser en faisant 2 overlay, dans le premier to override mesa (mesonFlags + postFixup - essayer programmatiquement ou hardcoding) et dans le deuxieme referencer le mesa.driver comme tu pensais)
    - [ ] option 2: creer un wrapper autour d'alacritty pour faire le link necessaire au depart /run/opengl-driver (te dire qu'il y aura un wrapper que pour Linux, sur MacOS ca marche out of the box)
  - [ ] mettre le script d'install dans build-env à mettre dans postBuild (stow pourrait etre utilisé comme nativeBuildInputs dedans par exemple pour linker les fonts), il faudrait juste remplacer dans le code le place holder pour $HOME -> fais gaffe, comment se passerait la desinstallation ??, au mieux tu generes un script d'install et de desinstall, qui porrait utiliser stow pour le coup

- Zsh
  - [ ] starship: tester sans les fonts et verifier que ca marchotte, sinon installer starship que si les fonts sont installées

- Script d'install
  - [ ] avoir une option pour installer terminal-packages ou pas (cf. installation sur une machine remote)

- Tmux :
  - [ ] update default command to use `zsh` (use relative path on purpose so it resolves to nix one when necessary)


- question gc sur les nix-channels (apres un upgrade) :
  - there is no command to remove old generations of a channel, you need to remove it manually in `/nix/var/nix/profiles` (`/nix/var/nix/gcroot` holds a symlink to profiles)
    -> do the test

- why do I have nix twice in the path in tmux ?

- [x] look into buildenv
  - buildenv: runCommand -> cree une derivation avec mkderviation avec un attribut buildCommand, dans le script setup.sh dans la fonction genericBuild, la commande $buildCommand est exécutée si elle existe puis genericBuild return tout de suite après
  - buildenv ne fait que merger les liens de tous les packages en un seul (eg. foo/bin/foo-exec et bar/bin/bar-exec -> my-env/bin/foo-exec + my-env/bin/bar-exec
- [ ] look into home manager -> Mouais

- install and configure :
  - [x] git
  - [x] tmux
  - [x] fzf
  - zsh :
    - [x] zsh
    - plugins :
      - [ ] starship for prompt (direct install with Nix (rust package - understand how zsh uses native binaries)
      - [ ] starship requires fonts installed in the terminal - try to make it clear that this is a runtime dependency
      - [ ] https://github.com/agkozak/zsh-z
      - [ ] https://github.com/zsh-users/zsh-syntax-highlighting
      - [ ] https://github.com/zsh-users/zsh-autosuggestions
  - [ ] neovim (plugins ?) (neovim - check https://www.youtube.com/watch?v=stqUbv-5u2s)
