#!/bin/bash
# A simple script to bootstrap the dotfiles installation

set -e

# Check if Nix is installed
if ! command -v nix &>/dev/null; then
  echo "Nix is not installed. Installing now..."
  sh <(curl -L https://nixos.org/nix/install)

  # Source nix
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
else
  echo "Nix is already installed."
fi

# Enable experimental features
export NIX_CONFIG="experimental-features = nix-command flakes"

# Clone repository if not already there
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone https://github.com/mikesplain/dotfiles.git "$DOTFILES_DIR"
fi

# Enter the dotfiles directory
cd "$DOTFILES_DIR"

# Run the darwin installer
echo "Installing nix-darwin configuration..."
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .

echo "Installation complete! Your system has been configured."
echo "Run 'darwin-rebuild switch --flake ~/.dotfiles' to update your configuration in the future."
