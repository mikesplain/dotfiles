{ inputs, lib, user, hostName, osVersion, ...}:
let
  inherit (inputs)
    homebrew-cask
    homebrew-core
    homebrew-bundle
    # homebrew-sk8s
    nix-homebrew;
in
{
  imports = [ ./nix-homebrew.nix ];
  homebrew = {
    enable = true;
    brews = [
      "aws-sso-util"
      "k9s"
      "hcxtools"
      # "Sonos-Inc/pdsw-engx-devops-sk8s/sk8s"
      "ncdu"
    ];
    casks = (if osVersion >= "14" then
    [
      "jordanbaird-ice"
    ] else []) ++
    [
      "session-manager-plugin"
      "appcleaner"
      "1password-cli"
    ];

    # casks = [];
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      # "1password" = 1333542190;
    };
  };
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
      # "Sonos-Inc/homebrew-pdsw-devops" = homebrew-sk8s;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}