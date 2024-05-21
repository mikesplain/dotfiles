{ inputs, lib, user, ... }: let
  inherit (inputs)
    homebrew-cask
    homebrew-core
    homebrew-bundle
    nix-homebrew;
in nix-homebrew.darwinModules.nix-homebrew {
  inherit lib;
  nix-homebrew = {
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    # enableRosetta = true;

    # User owning the Homebrew prefix
    user = user.name;

    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}