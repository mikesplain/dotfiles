{ pkgs, ... }: {
  programs.git = {
    enable = true;
    # TODO: configure git with nix
    # userName = config.cfg.user.name;
    # userEmail = config.cfg.user.email;
};

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

  programs.rio = {
    enable = true;
    settings = {
      # https://raphamorim.io/rio/docs/config/
      cursor = {
        shape = "Block";
      };
      fonts = {
        family = "MesloLGS Nerd Font Mono";
      };
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

      shell = "${pkgs.zsh}/bin/zsh";

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