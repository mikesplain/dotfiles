{pkgs, user, ...}: {
  imports = [ ./homebrew ];

  system.stateVersion = 5;

  security.pam.services.sudo_local.touchIdAuth = true;
  # fonts.fontDir.enable = true;
# fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
  fonts.packages = [pkgs.nerd-fonts.meslo-lg];

  nix.package = pkgs.nixVersions.latest;
  # Disabling due to https://github.com/NixOS/nix/issues/7273#issuecomment-1325073957
  nix.settings.auto-optimise-store = false;
  nix.settings.trusted-users = [ user.name ];
  nix.settings.max-jobs = 10;

  programs.zsh.enable = true;

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
      AppleKeyboardUIMode = 3;
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
    systemPackages = with pkgs; [ nixfmt-classic git coreutils ];
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
