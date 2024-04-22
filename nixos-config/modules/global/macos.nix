{ config, lib, pkgs, options, pwnvim, ... }: {
  cfg.os.name = "macos";
  system.stateVersion = 4;

  homebrew = {
    enable = true;
    brews = [
      "aws-sso-util"
      "k9s"
    ];
    casks = [
      "session-manager-plugin"
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

  environment = {
    shells = with pkgs; [zsh];
    loginShell = pkgs.zsh;
    systemPackages = [pkgs.coreutils];
    pathsToLink = ["/Applications"];
  };

  # users.users."mike.splain" = {
  #   home = "/Users/mike.splain";
  #   # shell = pkgs.zsh;
  # };
  fonts.fontDir.enable = true;
  # fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
  fonts.fonts = [(pkgs.nerdfonts)];
  security.pam.enableSudoTouchIdAuth = true;
  services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    dock.autohide = true;
    finder._FXShowPosixPathInTitle = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };
}