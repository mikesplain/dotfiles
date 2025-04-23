{
  inputs,
  lib,
  user,
  hostname,
  osVersion,
  platform,
  ...
}: let
  inherit (inputs)
    homebrew-cask
    homebrew-core
    homebrew-bundle
    homebrew-services
    nix-homebrew;
in {
  # Import the nix-homebrew module
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    enable = true;
    brews = [
      "hashcat"
      "hcxtools"
      "k9s"
      "ncdu"
      "telnet"
    ];
    casks =
      (if osVersion >= "14" then [ "jordanbaird-ice" ] else []) ++
      (if platform.isArm then [ "lm-studio" ] else []) ++ [
        "1password-cli"
        "1password"
        "appcleaner"
        "disk-inventory-x"
        "docker"
        "elgato-stream-deck"
        "ghostty"
        "google-chrome"
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

    # Mac App Store apps
    # These app IDs are from using the mas CLI app (mac app store)
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    masApps = if user.name != "runner" then {
      "GoodLinks" = 1474335294;
      "TestFlight" = 899247664;
      "The Unarchiver" = 425424353;
      "Things" = 904280696;
      "Velja" = 1607635845;
      "WireGuard" = 1451685025;
    } else {};
  };

  # Nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    user = user.name;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "homebrew/homebrew-services" = homebrew-services;
    };
    mutableTaps = true;
    autoMigrate = true;
  };
}