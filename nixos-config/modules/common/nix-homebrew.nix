{
  inputs,
  config,
  lib,
  nix-homebrew,
  ...}: let
  # Based on https://github.com/eaksa/eaksa/blob/3cb3dea18f61a964d7276716fd8d6401fb00b687/platforms/darwin/homebrew/nix-homebrew.nix and https://github.com/vladzaharia/nix-darwin-config/blob/5b0e92f9ef1d4ebebfbc63a3858c638df8054337/src/modules/nix-homebrew.nix
    inherit (inputs)
    homebrew-cask
    homebrew-core
    homebrew-bundle
    nix-homebrew;
  in nix-homebrew.darwinModules.nix-homebrew {
    inherit lib;
    nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        # enableRosetta = true;

        # User owning the Homebrew prefix
        user = config.cfg.user.name;

        taps = {
          "homebrew/homebrew-core" = homebrew-core;
          "homebrew/homebrew-cask" = homebrew-cask;
          "homebrew/homebrew-bundle" = homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
    };
}