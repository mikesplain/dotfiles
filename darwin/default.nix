{
  pkgs,
  user,
  inputs,
  platform,
  osVersion,
  ...
}:
{
  imports = [ ./homebrew.nix ];

  system.stateVersion = 5;

  system.activationScripts.extraActivation.text = ''
    ln -sf "${pkgs.jdk}/zulu-17.jdk" "/Library/Java/JavaVirtualMachines/"
  '';

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = false; # Disabled due to https://github.com/NixOS/nix/issues/7273#issuecomment-1325073957
      trusted-users = [ user.name ];
      max-jobs = 10;
      experimental-features = "nix-command flakes";
    };
  };

  programs.zsh.enable = true;

  system = {
    primaryUser = user.name;
    defaults = {
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
        AppleInterfaceStyleSwitchesAutomatically = false;
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
  };

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      # Core packages
      nixfmt-classic
      git
      coreutils
      pwnvim
      zoxide
      # Development tools
      # asdf-vm
      # awscli is now installed via Homebrew (see homebrew.nix)
      bashInteractive
      bat
      curl
      delta
      fd
      jdk
      jq
      kubectx
      ripgrep
      tree
      wget
    ];
    pathsToLink = [
      "/Applications"
      "/share/zsh"
    ];
  };
}
