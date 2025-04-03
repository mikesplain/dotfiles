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
      "telnet"
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
        "1password"
        "appcleaner"
        "disk-inventory-x"
        "docker"
        "elgato-stream-deck"
        "ghostty"
        "google-chrome"
        # "google-chrome@canary"
        # "google-chrome@dev"
        "gpg-suite"
        "logi-options-plus"
        "obsidian"
        "raycast"
        "session-manager-plugin"
        "shottr"
        "spotify"
        "stats"
        "vagrant"
        "virtualbox"
	      "visual-studio-code"
        "zen-browser"
      ];

    # casks = [];
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = if user.name != "runner" then {
      "GoodLinks" = 1474335294;
      "TestFlight" = 899247664;
      "The Unarchiver" = 425424353;
      "Things" = 904280696;
      "Velja" = 1607635845;
      "WireGuard" = 1451685025;
    } else {};
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
