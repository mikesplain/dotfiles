{
  config,
  lib,
  pkgs,
  options,
  pwnvim,
  ...
}: {
  cfg.os.name = "macos";
  system.stateVersion = 4;

  homebrew = {
    enable = true;
    brews = [
      "aws-sso-util"
      "k9s"
      "hcxtools"
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
    pathsToLink = [
      "/Applications"
      "/share/zsh"
    ];
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
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowStatusBar = true;
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
      _FXShowPosixPathInTitle = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    dock = {
      autohide = true;
      minimize-to-application = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.25;
    };
    screencapture.location = "/Users/${config.cfg.user.name}/Downloads";
  };
}
