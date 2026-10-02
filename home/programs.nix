{ pkgs, ... }:
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
      "1Password/config"
    ];

    settings = {
      "*.brew.sh" = {
        User = "brewadmin";
        ForwardAgent = true;
      };

      "*.ec2.internal" = {
        CanonicalizeHostname = "yes";
        CanonicalizeMaxDots = "3";
        CanonicalDomains = "sslip.io";
      };

      "*.us-east-2.compute.internal" = {
        CanonicalizeHostname = "yes";
        CanonicalizeMaxDots = "3";
        CanonicalDomains = "sslip.io";
      };

      "bastion.*" = {
        ForwardAgent = true;
      };

      # GitHub authentication must select an account before the repository path
      # reaches GitHub. Bookmark ssh://git@github-{personal,work,managed} on each
      # corresponding key in 1Password and enable generated SSH config files.
      # The included 1Password/config supplies the matching public key; do not pin
      # generated fingerprints here. IdentityFile none suppresses default files
      # when a bookmark is missing, while retaining keys from the earlier include.
      "github-personal github-work github-managed" = {
        # SSH over port 443 avoids networks that intermittently block port 22.
        # Both GitHub endpoints use the same host keys.
        HostName = "ssh.github.com";
        Port = 443;
        HostKeyAlias = "github.com";
        ConnectTimeout = 10;
        ConnectionAttempts = 1;
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = "none";
        # Avoid sharing authenticated connections between GitHub identities.
        ControlMaster = "no";
        ControlPath = "none";
      };

      "github.com" = {
        User = "git";
        ControlMaster = "no";
      };

      # This won't work in most cases because this requires the public key to already be on the instance and we don't use keys.
      # "i-* mi-*" = {
      #   ProxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      # };

      # Default configuration for all hosts
      "*" = {
        # Use the 1Password SSH agent for key discovery (works even when
        # SSH_AUTH_SOCK isn't inherited, e.g. IDEs/cron). OpenSSH expands the
        # leading ~ in this quoted value. All of this machine's SSH keys live in
        # the 1Password agent, so pointing every host at it is safe.
        # NOTE: home-manager's ssh module renders values verbatim and does not
        # auto-quote, so the surrounding quotes must be in the value itself — the
        # path contains a space ("Group Containers"). Without them ssh splits it
        # into two tokens and the whole config fails to parse.
        IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
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
      };
    };
  };

  # Terminal emulators
  programs.ghostty = {
    enable = true;
    package = null; # Managed via Homebrew cask instead for faster updates
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
      confirm-close-surface = false;
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
