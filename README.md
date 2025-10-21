# Mike Splain's Nix Dotfiles

[![Nix Test](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml/badge.svg)](https://github.com/mikesplain/dotfiles/actions/workflows/nix-test.yaml)

Opinionated `nix-darwin` and Home Manager configuration for bringing a clean macOS install up to a reproducible workstation in one rebuild.

## Quick Start

1. Install Nix on macOS (if it is not already installed):

   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Clone the dotfiles and enter the repository:

   ```bash
   git clone https://github.com/mikesplain/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. Perform the first system activation with the same command CI runs:

   ```bash
   nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake .
   ```

4. For day-to-day updates after the initial activation:

   ```bash
   darwin-rebuild switch --flake .
   ```

5. Drop into the development shell whenever you need project tooling (`nixfmt`, `prettier`, git hooks, etc.):

   ```bash
   nix develop
   ```

For first-time setups, `./bootstrap.sh` installs basic prerequisites before the Nix rebuild, while the flake handles all macOS and user configuration on subsequent runs.

## Project Layout

```
flake.nix             # Single entry point wiring hosts, Home Manager, and shared inputs
flake.lock            # Pinned flake inputs
darwin/               # macOS (nix-darwin) modules
  default.nix         # Base host configuration
  homebrew.nix        # Brew taps/casks (kept OS-specific)
home/                 # Home Manager modules (per-user programs, services, dotfiles)
  default.nix         # Aggregates user-level modules
  git.nix             # Git configuration and templates
  programs.nix        # CLI and application enablement
  shell.nix           # Shell environment (zsh, completions)
  tmux.nix            # Tmux defaults and theme
templates/            # Reusable text assets (gitconfig templates, placeholder secrets)
devshell.nix          # Development shell definition for contributors
bootstrap.sh          # Convenience script for bootstrapping fresh machines
```

## Everyday Commands

- `darwin-rebuild switch --flake .` — Apply configuration changes to the current machine.
- `nix develop` — Enter the dev shell with formatters and pre-commit hooks configured.
- `pre-commit run --all-files` — Lint and format Nix and text assets to match CI.
- `nix flake update` — Refresh inputs and rewrite `flake.lock` when bumping dependencies.

## Validation & Testing

- Run `darwin-rebuild switch --flake .` (or the CI command from Quick Start) after edits to confirm the macOS build succeeds.
- Use `nix flake check` to evaluate Home Manager modules on both `aarch64-darwin` and `x86_64-darwin`.
- Source the interactive shell with `zsh -vc "source ~/.zshrc"` to ensure the login environment stays clean.

## Troubleshooting

### Reinstall mount error

If you hit a mount error while reinstalling Nix, ensure `/sbin` is on your `PATH`:

```bash
export PATH="/sbin:${PATH}"
sh <(curl -L https://nixos.org/nix/install)
```

## Uninstallation

```bash
# Ensure nixpkgs is configured
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# Remove the nix-darwin configuration (may require multiple runs)
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller

# Uninstall Nix itself
/nix/nix-installer uninstall

# Troubleshoot any disk access issues
/usr/sbin/diskutil
/bin/launchctl
```
