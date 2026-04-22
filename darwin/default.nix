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
    # Prefer stable to maximize cache hits; latest can trigger full source builds/tests.
    package = pkgs.nixVersions.stable;
    settings = {
      auto-optimise-store = false; # Disabled due to https://github.com/NixOS/nix/issues/7273#issuecomment-1325073957
      trusted-users = [ user.name ];
      max-jobs = 10;
      experimental-features = "nix-command flakes";
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      interval = {
        Weekday = 0; # Run on Sunday
        Hour = 3; # At 3 AM
        Minute = 0;
      };
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
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;
        "com.apple.swipescrolldirection" = true;
      };
      trackpad = {
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
      };
      dock = {
        autohide = true;
        minimize-to-application = true;

        showAppExposeGestureEnabled = true;
        showDesktopGestureEnabled = true;
        showLaunchpadGestureEnabled = true;
        showMissionControlGestureEnabled = true;

        autohide-delay = 0.0;
        autohide-time-modifier = 0.25;
        tilesize = 40;
        wvous-br-corner = 14;
        # Dock snapshot from the current laptop, kept here as a reference for a
        # future declarative Dock but not enforced for now.
        # show-recents = true;
        # persistent-apps = [
        #   { app = "/System/Applications/Apps.app"; }
        #   { app = "/Applications/Microsoft Outlook.app"; }
        #   { app = "/System/Applications/Safari.app"; }
        #   { app = "/Applications/Google Chrome.app"; }
        #   { app = "/Applications/Zen.app"; }
        #   { app = "/System/Applications/Messages.app"; }
        #   { app = "/Applications/Webex.app"; }
        #   { app = "/Applications/Slack.app"; }
        #   { app = "/Applications/Ghostty.app"; }
        #   { app = "/Applications/Windsurf.app"; }
        #   { app = "/Applications/Cursor.app"; }
        #   { app = "/Applications/Visual Studio Code.app"; }
        #   { app = "/Applications/Things3.app"; }
        #   { app = "/System/Applications/Reminders.app"; }
        #   { app = "/Applications/Codex.app"; }
        #   { app = "/Applications/GoodLinks.app"; }
        #   { app = "/System/Applications/Maps.app"; }
        #   { app = "/Applications/Microsoft OneNote.app"; }
        #   { app = "/Applications/Obsidian.app"; }
        #   { app = "/System/Applications/Calendar.app"; }
        #   { app = "/System/Applications/Notes.app"; }
        #   { app = "/System/Applications/Freeform.app"; }
        #   { app = "/System/Applications/Photos.app"; }
        #   { app = "/System/Applications/News.app"; }
        #   { app = "/System/Applications/App Store.app"; }
        #   { app = "/System/Applications/iPhone Mirroring.app"; }
        #   { app = "/System/Applications/System Settings.app"; }
        # ];
        # persistent-others = [
        #   {
        #     folder = {
        #       path = "/Users/${user.name}/Downloads";
        #       arrangement = "date-modified";
        #       displayas = "stack";
        #       showas = "fan";
        #     };
        #   }
        # ];
      };
      WindowManager = {
        GloballyEnabled = false;
        HideDesktop = true;
      };
      screencapture.location = "/Users/${user.name}/Downloads";
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };
    };
  };

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      # Core packages
      nixfmt
      git
      coreutils
      neovim
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
      nixd
      tree
      wget
    ];
    pathsToLink = [
      "/Applications"
      "/share/zsh"
    ];
  };
}
