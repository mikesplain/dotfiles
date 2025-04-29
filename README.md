# Mike Splain's Nix Dotfiles

[![Nix Test](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml/badge.svg)](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml)

A simplified Nix configuration for setting up macOS machines with a consistent environment.

## Directory Structure

```
flake.nix                  # Main entry point for Nix configuration
darwin/                    # macOS specific configurations
  default.nix              # Main system configuration
  homebrew.nix             # Homebrew packages
home/                      # Home-manager configurations
  default.nix              # Main home-manager setup
  git.nix                  # Git configuration
  programs.nix             # Terminal and application configs
  shell.nix                # Shell configurations (zsh)
  tmux.nix                 # Tmux configuration
templates/                 # Template files
  gitconfig/               # Git configuration templates
    personal.tmpl          # Personal git configuration
    work.tmpl              # Work git configuration
```

## Installation

```bash
# Install nix if needed
sh <(curl -L https://nixos.org/nix/install)

# Clone this repository
git clone https://github.com/mikesplain/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Initial installation
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .

# Subsequent updates
darwin-rebuild switch --flake .

# Update flakes
nix flake update
```

## Troubleshooting

### Reinstall mount error

If you get a mount error during reinstall of nix, try checking path for sbin:

```bash
export PATH="/sbin:${PATH}"
sh <(curl -L https://nixos.org/nix/install)
```

### Uninstallation

```bash
# Make sure nixpkgs is setup:
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# Uninstall darwin
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
# May need to run multiple times

# Uninstall nix
/nix/nix-installer uninstall

# If there are issues with disk access
/usr/sbin/diskutil
/bin/launchctl
```
