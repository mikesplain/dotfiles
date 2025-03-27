[![Tests](https://github.com/mikesplain/dotfiles/actions/workflows/tests.yml/badge.svg)](https://github.com/mikesplain/dotfiles/actions/workflows/tests.yml) [![Nix Test](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml/badge.svg)](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml) [![CI](https://github.com/mikesplain/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/mikesplain/dotfiles/actions/workflows/ci.yaml)


# Mike Splain's Nix Config / Dotfiles

Referenced heavily: https://github.com/computercam/_unixconf_nix
https://github.com/LnL7/nix-darwin

New reference: https://github.com/eaksa/eaksa/blob/main/flake.nix

## Commands
```
# Install nix if needed
sh <(curl -L https://nixos.org/nix/install)

# Installing nix-darwin
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .
# Using nix-darwin
darwin-rebuild switch --flake .
# Update flakes
nix flake update
# Switch to new flakes, might need above command instead.
home-manager switch
```

## Reinstall mount error:
If you get a mount error during reinstall of nix try checking path for sbin

Discovered via: https://github.com/DeterminateSystems/nix-installer/issues/749

```
export PATH="/sbin:${PATH}"
sh <(curl -L https://nixos.org/nix/install)
```

## Uninstall
- Nix darwin first
```
# Make sure nixpkgs is setup:
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# this or the included darwin-uninstaller command.
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
# Might need to run multiple times to make sure

# Once successful run the nix uninstaller:
/nix/nix-installer uninstall

# If there are issues with the disk, might need to use hard coded path
/usr/sbin/diskutil
/bin/launchctl
```
