{
  inputs,
  lib,
  user,
  hostName,
  osVersion,
  platform,
  ...
}: let
  inherit
    (inputs)
    homebrew-cask
    homebrew-core
    homebrew-bundle
    homebrew-services
    # homebrew-sk8s

    nix-homebrew
    ;
in {
  imports = [./nix-homebrew.nix];
  homebrew = {
    enable = true;
    brews = [
      "aws-sso-util"
      "hashcat"
      "hcxtools"
      "k9s"
      "ncdu"
    ];
    casks =
      (
        if osVersion >= "14"
        then [
          "jordanbaird-ice"
        ]
        else []
      )
      ++
      (
        if platform.isArm
        then [
          "lm-studio"
        ]
        else []
      )
      ++ [
        "1password-cli"
        "appcleaner"
        "disk-inventory-x"
        "docker"
        "elgato-stream-deck"
        "ghostty"
        "google-chrome"
        "logi-options-plus"
        "raycast"
        "session-manager-plugin"
        "shottr"
        "spotify"
        "virtualbox"
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
      "homebrew/homebrew-services" = homebrew-services;
      # "Sonos-Inc/homebrew-pdsw-devops" = homebrew-sk8s;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
