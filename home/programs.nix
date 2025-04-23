{pkgs, ...}: {
  # VSCode
  programs.vscode = {
    enable = true;
  };

  # SSH Configuration
  programs.ssh = {
    enable = true;
    includes = [
      "config.d/*"
    ];
    extraConfig = ''
      Host *.brew.sh
        User brewadmin
        ForwardAgent yes

      Host *.ec2.internal
        CanonicalizeHostname yes
        CanonicalizeMaxDots 3
        CanonicalDomains sslip.io

      Host *.us-east-2.compute.internal
        CanonicalizeHostname yes
        CanonicalizeMaxDots 3
        CanonicalDomains sslip.io

      Host bastion.*
        ForwardAgent yes

      # Personal GitHub
      Host personalgit
        HostName github.com
        User git
        IdentityFile ~/.ssh/personal_git.pub
        IdentitiesOnly yes

      # Work GitHub
      Host workgit
        HostName github.com
        User git
        IdentityFile ~/.ssh/work_git.pub
        IdentitiesOnly yes

      Host i-* mi-*
        ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"

      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        StrictHostKeyChecking ask
        VerifyHostKeyDNS ask
        NoHostAuthenticationForLocalhost yes
        ControlMaster auto
        ControlPath /tmp/ssh-%C.socket
    '';
  };

  # Terminal emulators
  programs.ghostty = {
    enable = true;
    package = null; # Ghostty is currently marked as broken for macOS
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      background-opacity = 0.8;
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