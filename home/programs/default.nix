{pkgs, ...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow";
    defaultOptions = ["-m --bind ctrl-a:select-all,ctrl-d:deselect-all"];
  };

  programs.eza.enable = true;
  programs.bash.enable = true;
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.vscode = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      kubernetes = {
        #format = 'on [⛵ ($user on )($cluster in )$context \($namespace\)](dimmed green) ';
        disabled = false;
        contexts = [
          {
            context_pattern = "arn:aws:eks:(?P<region>[\\w-]+):.*\\/(?P<cluster>[\\w-]+)";
            context_alias = "eks/$region/$cluster";
          }
        ];
      };
    };
  };

  # Enable SSH Config: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.enable
  programs.ssh = {
    enable = true;
    includes = [
      "config.d/*"
    ];
    extraConfig = ''
      Host *.brew.sh
        User brewadmin
        ForwardAgent yes

      # Host remote.github.net remote.github.com
      #   ForwardAgent yes
      #   User mikesplain

      # Host *.github.com *.github.net *.githubapp.com
      #   ForwardAgent no
      #   User mikesplain

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
        # IdentityFile ~/.ssh/id_rsa
        ControlMaster auto
        ControlPath /tmp/ssh-%C.socket
    '';
  };

  # programs.rio = {
  #   enable = true;
  #   settings = {
  #     # https://raphamorim.io/rio/docs/config/
  #     cursor = {
  #       shape = "Block";
  #     };
  #     fonts = {
  #       family = "MesloLGS Nerd Font Mono";
  #     };
  #   };
  # };

  programs.ghostty = {
    enable = true;

    # Ghostty is currently marked as broken for macOS
    package = null;

    # enableBashIntegration = true;
    # enableZshIntegration = true;
    # Disabled due to package issue above
    # installVimSyntax = true;


    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ghostty.settings
    settings = {
      # Copied from dot_config/ghostty/config
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
    # Settings from dustinlyons
    # https://alacritty.org/config-alacritty.html
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

        # This option doesn't seem to work and can probably be removed later
        # option_as_alt= "Both";
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

      # Enabling thse break bash and don't fix zsh so... they can be remove at some point
      # https://github.com/alacritty/alacritty/issues/474
      # keyboard = {
      #   bindings = [
      #     { key = "Left";     mods = "Alt";     chars = "\x1bb";                          } # Skip word left
      #     { key = "Right";    mods = "Alt";     chars = "\x1bf";                          } # Skip word right
      #     { key = "Left";     mods = "Command"; chars = "\x1bOH";   mode = "AppCursor";   } # Home
      #     { key = "Right";    mods = "Command"; chars = "\x1bOF";   mode = "AppCursor";   } # End
      #     { key = "Back";     mods = "Command"; chars = "\x15";                           } # Delete line
      #     { key = "Back";     mods = "Alt";     chars = "\x1b\x7f";                       } # Delete word
      #   ];
      # };
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

