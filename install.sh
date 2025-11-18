# Pre-requisites:
# - nix / nix-env / nix-shell

clone_this_repository ()
{
  nix-shell -p git --command "git clone https://github.com/paulroseau/dotfiles $HOME/.dotfiles"
}

create_config_symlinks () {
  pushd $HOME/.dotfiles
  for package in $(ls configs); do
    nix-shell -p stow --command "stow --dotfiles --dir configs --target $HOME $package"
    echo "$package stowed"
  done
  popd
}

clone_this_repository
create_config_symlinks

# TODO clean what is below up

# Install applications
# TODO ask if you are installing on a remote workstation or locally (to install Alacritty)
nix-env -if nix/default.nix -A myPkgs.local

# link fonts here (this is for wezterm, to not have to distinguish between Linux ~/.fonts and MacOS, this could probably be done better)
ln -s $HOME/.nix-profile/share/fonts .


# Basic install script for Debian only

# Alacritty install
sudo ln -s $HOME/.nix-profile/share/applications/Alacritty.desktop /usr/local/share/applications/
sudo ln -s $HOME/.nix-profile/share/icons/hicolor/scalable/apps/Alacritty.svg /usr/share/pixmaps/

# Optional (if still using Alacritty) which needs fonts installed on the system
ln -s $HOME/.nix-profile/fonts $HOME/.fonts # Note: in https://www.youtube.com/watch?v=fR4ThXzhQYI the guy puts them in .local/share/fonts
rm $HOME/.cache/fontconfig/* # for good measure, spent hours understanding why fonts were not loaded

# For Mac OS

# We use -L with cp below because MacOS does not follow sym links for these funcionalities
# A better approach could resort on using `rsync` with the options that nix-darwin uses https://github.com/nix-community/home-manager/issues/1341#issuecomment-2748323255

# Make applications available from launchpad and spotlight
cp -rL ~/.nix-profile/Applications/* ~/Applications/
# TODO you need to use rsync for the following (replace existing target but don't mach source)
rsync --unsafe-link-copy ~/.nix-profile/Library ~/Library

# Optional (if still using Alacritty) which needs fonts installed on the system
# Add NerdFonts (you may need to restart for them to appear)
cp -Lr ~/.nix-profile/share/fonts/* ~/Library/Fonts/

# Go to Privacy & Security settings, Full Disk Access, tick Alacritty (otherwisse you can't ls in ~/Documents, ~/Downloads with GNU ls)
# Install Karabiner
