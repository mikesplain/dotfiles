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

      # GitHub: one shared endpoint for all three accounts.
      #
      # No IdentityFile: the 1Password SSH agent (see
      # ~/.config/1Password/ssh/agent.toml) offers the git keys in order and GitHub
      # accepts the one registered for the target account. Keys are pulled live from
      # the agent, so rotating a key in 1Password needs no changes here.
      #
      # ControlMaster is disabled for github.com specifically: a shared master would
      # cache the first account's auth and break pushes to the other accounts on the
      # same host.
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
