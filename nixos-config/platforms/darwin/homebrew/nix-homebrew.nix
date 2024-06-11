{ inputs, lib, user, ... }: let
  inherit (inputs)
    nix-homebrew;
in nix-homebrew.darwinModules.nix-homebrew {
  inherit lib;
}