# Nix Config
(Rename repo eventually)

Referenced heavily: https://github.com/computercam/_unixconf_nix
https://github.com/LnL7/nix-darwin

New reference: https://github.com/eaksa/eaksa/blob/main/flake.nix

## Commands
```
# Install nix if needed
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

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
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

## Uninstall
- Nix darwin first
```
# Make sure nixpkgs is setup:
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# this or the included darwin-uninstaller command.
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
./result/bin/darwin-uninstaller

# If there are issues with the disk, might need to use hard coded path
/usr/sbin/diskutil
/bin/launchctl
```

## TODO
- [ ] Fix brokenm option + arrow keys
- [ ] Secrets, something like [ryantm/agenix](ryantm/agenix) via [this](https://github.com/dustinlyons/nixos-config/blob/7d6141768134a329b1cf4096d923268359c31a0d/flake.nix#L5C26-L5C39)
- [ ] Speed of the term slowed down as soon as I added homebrew back. I should try to remove it or reduce autoloaded modules like autocomplete stuff