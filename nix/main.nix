{ pkgs 
, sources 
}:

with pkgs;

let
  alacrittyPackages = callPackage ./alacritty.nix {
    alacrittyThemeSource = sources.alacritty-theme;
  };

  zshPackages = 
    let
      zshPlugins = [
        zsh-autosuggestions
        zsh-syntax-highlighting
      ];

    in [ zsh starship ] ++ zshPlugins;

  neovimPackages = callPackage ./neovim {
    inherit sources;
  };

  /* 
  Note: 
  These binaries are necessary/recommended for the fzf-lua plugin to work properly.

  The fzf-lua plugin expects looks up these binaries from the PATH environment
  variable.

  An extreme approach would have been to patch the plugin to replace occurences of
  those binaries by their full path such as ${ripgrep}/bin/rg but that's not
  easy to maintain.

  An alternative would have been to wrap the `nvim` executable in a script where we
  set the PATH environment variable to hold only the paths to these required
  executables.

  However since we also want to use those binaries on their own, it just makes
  sense to install them directly and not as dependencies of nvim.
  */
  fzfLuaBinaries = [
    fzf
    ripgrep
    fd
    bat
    delta
  ];

  miscBinaries = [
    # git # not working on Google laptop
    tig
    tmux
    jq
    yq
  ];

  nixBinaries = [
    niv
    nix
  ];

  kubernetesBinaries = [
    # k9s # not working on Google laptop, needs to be compiled with patched go
    kubectl
    kubectl-tree
  ];

  testPackages = [
    s3cmd
    bazel
  ];

in 
  rec {
      base =
        fzfLuaBinaries
        ++ kubernetesBinaries
        ++ miscBinaries
        ++ neovimPackages
        ++ nixBinaries
        ++ zshPackages;

      test = testPackages;

      local = base ++ alacrittyPackages;
  }
