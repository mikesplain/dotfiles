{pkgs, user, ...}: {
  imports = [ ./homebrew ];

  services.nix-daemon.enable = true;
  system.stateVersion = 4;

  security.pam.enableSudoTouchIdAuth = true;
  fonts.fontDir.enable = true;
# fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
  fonts.fonts = [(pkgs.nerdfonts)];

  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [ user.name ];
  nix.maxJobs = 10;

  system.defaults = {
    # LaunchServices = {
    #   LSQuarantine = false;
    # };
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
      AppleInterfaceStyle = "Dark";
      InitialKeyRepeat = 14;
      KeyRepeat = 1;
    };
    dock = {
      autohide = true;
      minimize-to-application = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.25;
    };
    screencapture.location = "/Users/${user.name}/Downloads";
  };

  environment = {
    shells = with pkgs; [zsh];
    loginShell = pkgs.zsh;
    systemPackages = with pkgs; [ nixfmt git coreutils ];
    pathsToLink = [
      "/Applications"
      "/share/zsh"
    ];
  };

  # system.keyboard = {
  #   enableKeyMapping = true;
  #   userKeyMapping = [
  #     # See https://developer.apple.com/library/archive/technotes/tn2450/_index.html
  #     # for documentation on key remapping in MacOS
  #     {
  #       # Caps Lock -> Escape
  #       HIDKeyboardModifierMappingSrc = 30064771129;
  #       HIDKeyboardModifierMappingDst = 30064771113;
  #     }
  #     {
  #       # Function -> Left GUI (Command)
  #       HIDKeyboardModifierMappingSrc = 1095216660483;
  #       HIDKeyboardModifierMappingDst = 30064771299;
  #     }
  #     {
  #       # Left GUI (Command) -> Left Alt (Option)
  #       HIDKeyboardModifierMappingSrc = 30064771299;
  #       HIDKeyboardModifierMappingDst = 30064771298;
  #     }
  #     {
  #       # Right GUI (Command) -> Right Alt (Option)
  #       HIDKeyboardModifierMappingSrc = 30064771303;
  #       HIDKeyboardModifierMappingDst = 30064771302;
  #     }
  #     {
  #       # Left Alt (Option) -> Function
  #       HIDKeyboardModifierMappingSrc = 30064771298;
  #       HIDKeyboardModifierMappingDst = 1095216660483;
  #     }
  #     {
  #       # Right Alt (Option) -> Function
  #       HIDKeyboardModifierMappingSrc = 30064771302;
  #       HIDKeyboardModifierMappingDst = 1095216660483;
  #     }
  #   ];
  # };
}