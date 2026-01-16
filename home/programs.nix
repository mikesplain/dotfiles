{
  lib,
  pkgs,
  platform,
  ...
}:
{
  # VSCode
  programs.vscode = {
    enable = true;
  };

  # SSH Configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Disable deprecated default config
    includes = [
      "config.d/*"
    ];

    matchBlocks = {
      "*.brew.sh" = {
        user = "brewadmin";
        forwardAgent = true;
      };

      "*.ec2.internal" = {
        extraOptions = {
          CanonicalizeHostname = "yes";
          CanonicalizeMaxDots = "3";
          CanonicalDomains = "sslip.io";
        };
      };

      "*.us-east-2.compute.internal" = {
        extraOptions = {
          CanonicalizeHostname = "yes";
          CanonicalizeMaxDots = "3";
          CanonicalDomains = "sslip.io";
        };
      };

      "bastion.*" = {
        forwardAgent = true;
      };

      # Personal GitHub
      "personalgit" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personal_git.pub";
        identitiesOnly = true;
      };

      # Work GitHub
      "workgit" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/personal_git.pub";
        identitiesOnly = true;
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "/tmp/ssh-workgit-%C.socket";
          ControlPersist = "10m";
        };
      };

      # Managed Work GitHub
      "workgit_managed" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/workgit_managed.pub";
        identitiesOnly = true;
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "/tmp/ssh-workgit_managed-%C.socket";
          ControlPersist = "10m";
        };
      };

      # This won't work in most cases because this requires the public key to already be on the instance and we don't use keys.
      # "i-* mi-*" = {
      #   extraOptions = {
      #     ProxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      #   };
      # };

      # Default configuration for all hosts
      "*" = {
        extraOptions = {
          StrictHostKeyChecking = "ask";
          VerifyHostKeyDNS = "ask";
          NoHostAuthenticationForLocalhost = "yes";
          ControlMaster = "auto";
          ControlPath = "/tmp/ssh-%C.socket";
          # Add common SSH defaults that home-manager usually provides
          AddKeysToAgent = "yes";
          Compression = "yes";
          ServerAliveInterval = "60";
          ServerAliveCountMax = "3";
          HashKnownHosts = "yes";
          ControlPersist = "1800";
        }
        // lib.optionalAttrs platform.isDarwin {
          IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
        };
      };
    };
  };

  # Terminal emulators
  programs.ghostty = {
    enable = true;
    package = null; # Ghostty is currently marked as broken for macOS
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      background-opacity = 0.9;
      shell-integration = "zsh";
      shell-integration-features = "no-cursor";
      cursor-style = "block";
      cursor-style-blink = false;
      font-feature = "-calt";
      copy-on-select = "clipboard";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      cursor = {
        style = "Block";
      };

      terminal.shell = "${pkgs.zsh}/bin/zsh";

      window = {
        opacity = 1.0;
        padding = {
          x = 0;
          y = 0;
        };
        dynamic_padding = true;
        decorations = "full";
        title = "Terminal";
      };

      selection = {
        save_to_clipboard = true;
      };

      font = {
        normal = {
          family = "MesloLGS Nerd Font Mono";
          style = "Regular";
        };
        size = 14;
      };

      colors = {
        primary = {
          background = "0x1f2528";
          foreground = "0xc0c5ce";
        };

        normal = {
          black = "0x1f2528";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xc0c5ce";
        };

        bright = {
          black = "0x65737e";
          red = "0xec5f67";
          green = "0x99c794";
          yellow = "0xfac863";
          blue = "0x6699cc";
          magenta = "0xc594c5";
          cyan = "0x5fb3b3";
          white = "0xd8dee9";
        };
      };

      keyboard = {
        bindings = [
          {
            key = "Left";
            mods = "Alt";
            chars = "\\u001BB";
          }
          {
            key = "Right";
            mods = "Alt";
            chars = "\\u001BF";
          }
          {
            key = "Left";
            mods = "Command";
            chars = "\\u001bOH";
            mode = "AppCursor";
          }
          {
            key = "Right";
            mods = "Command";
            chars = "\\u001bOF";
            mode = "AppCursor";
          }
          {
            key = "Back";
            mods = "Command";
            chars = "\\u0015";
          }
        ];
      };
    };
  };
}
