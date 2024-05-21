{
  config,
  lib,
  pkgs,
  options,
  pwnvim,
  nixpkgs,
  inputs,
  ...
}:
with pkgs.stdenv;
with lib; let
  # fzshInitExtraConfig = import ./zshInitExtraConfig.nix;
  # zshInitExtraConfig = fzshInitExtraConfig { lib = lib; pkgs = pkgs; };
  # fgetZshInitExtra = import ./getZshInitExtra.nix;
  # getZshInitExtra = fgetZshInitExtra { lib = lib; pkgs= pkgs; zshInitExtraConfig = zshInitExtraConfig; };
in {
  nixpkgs.overlays = [
    (final: prev: {
      pwnvim = inputs.pwnvim.packages."${config.nixpkgs.hostPlatform}".pwnvim;
    })
  ];

  environment.systemPackages = with pkgs; [
    zoxide
    inputs.pwnvim.packages."${system}".default
  ];

  home-manager = {
    backupFileExtension = "backup";
    # When the below is set, nixpkg config in home manager is diabled, see https://nix-community.github.io/home-manager/nix-darwin-options.xhtml#nix-darwin-opt-home-manager.useGlobalPkgs
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit pwnvim;};

    users."${config.cfg.user.name}" = {
      home.stateVersion = config.cfg.os.version;

      programs.git = {
        enable = true;
        # TODO: configure git with nix
        # userName = config.cfg.user.name;
        # userEmail = config.cfg.user.email;
      };

      home.sessionVariables = {
        PAGER = "less";
        CLICOLOR = 1;
        EDITOR = "nvim";
      };

      # TODO: Consider using zsh init extra
      # programs.zsh.enable = true;
      # programs.zsh.initExtra = getZshInitExtra;

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "rg --files --hidden --follow";
        defaultOptions = ["-m --bind ctrl-a:select-all,ctrl-d:deselect-all"];
      };

      programs.eza.enable = true;
      programs.bat.enable = true;
      programs.bat.config.theme = "TwoDark";
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion = {
          enable = true;
        };
        syntaxHighlighting.enable = true;
        autocd = true;
        shellAliases = {
          ls = "eza -g";
          l = "eza -la";
          la = "l";
          ll = "l";
          # ls = "ls --color=auto -F";
          cp = "cp -rv";
          mkdir = "mkdir -vp";
          df = "df -H";
          rm = "rm -iv";
          mv = "mv -iv";
          k = "kubectl";
          x = "kubectx";
          kx = "kubectx";
          kns = "kubens";
          ktmux = "tmux new-session -d 'watch kubectl get nodes -L kops.k8s.io/instancegroup,node.kubernetes.io/instance-type' && tmux split-window -h 'watch kubectl get pods --all-namespaces --sort-by {.metadata.namespace}' && tmux split-window -v -t 1 && tmux -2 attach-session -d";
          clear_dns_cache = "dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
          gut = "git";
          cat = "bat";
          grep = "grep --color=auto";
          sf = "sk8s find";
          "cd ..." = "../..";
          "cd ...." = "../../..";
          "cd ....." = "../../../..";
          "cd ......" = "../../../../..";
          "cd ......." = "../../../../../..";
        };
        shellGlobalAliases = {
          "..." = "../..";
          "...." = "../../..";
          "....." = "../../../..";
          "......" = "../../../../..";
          "......." = "../../../../../..";
        };
        sessionVariables = {
          SHELL = "${pkgs.zsh}/bin/zsh";
          EDITOR = "nvim";
          TERM = "xterm-256color";
        };
        initExtra = ''
          eval $(${
            if system == "aarch64-darwin"
            then "/opt/homebrew/bin/brew"
            else "brew"
          } shellenv)
          autoload -U select-word-style
          select-word-style bash

          . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
          . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
        '';
      };

      programs.tmux = {
        enable = true;
        terminal = "xterm-256color";
        prefix = "C-b";
        escapeTime = 10;
        historyLimit = 50000;
        keyMode = "vi";
        mouse = false;

        plugins = with pkgs.tmuxPlugins; [
          vim-tmux-navigator
          sensible
          yank
          prefix-highlight
          {
            plugin = power-theme;
            extraConfig = ''
              set -g @tmux_power_theme 'coral'
            '';
          }
          # {
          #   plugin = resurrect; # Used by tmux-continuum

          #   # Use XDG data directory
          #   # https://github.com/tmux-plugins/tmux-resurrect/issues/348
          #   extraConfig = ''
          #     set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          #     set -g @resurrect-capture-pane-contents 'on'
          #     set -g @resurrect-pane-contents-area 'visible'
          #   '';
          # }
          # {
          #   plugin = continuum;
          #   extraConfig = ''
          #     set -g @continuum-restore 'on'
          #     set -g @continuum-save-interval '5' # minutes
          #   '';
          # }
        ];
        extraConfig = ''
          # Remove Vim mode delays
          set -g focus-events on

          # Enable full mouse support
          # set -g mouse on
          # set -g mouse-resize-pane on

          bind m set-option mouse\; display-message "Mouse #{?mouse,enabled,disabled}"

          # -----------------------------------------------------------------------------
          # Key bindings
          # -----------------------------------------------------------------------------

          set -g base-index 1           # start windows numbering at 1
          setw -g pane-base-index 1     # make pane numbering consistent with windows

          setw -g automatic-rename on   # rename window to reflect current program
          set -g renumber-windows on    # renumber windows when a window is closed

          set -g set-titles on          # set terminal title

          set -g display-panes-time 800 # slightly longer pane indicators display time
          set -g display-time 1000      # slightly longer status messages display time

          set -g status-interval 10     # redraw status line every 10 seconds

          # clear both screen and history
          bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history

          # activity
          set -g monitor-activity on
          set -g visual-activity off


          # -- navigation ----------------------------------------------------------------

          # create session
          bind C-c new-session

          # find session
          bind C-f command-prompt -p find-session 'switch-client -t %%'

          # session navigation
          bind BTab switch-client -l  # move to last session

          # split current window horizontally
          bind - split-window -v
          # split current window vertically
          bind _ split-window -h

          # pane navigation
          bind -r h select-pane -L  # move left
          bind -r j select-pane -D  # move down
          bind -r k select-pane -U  # move up
          bind -r l select-pane -R  # move right
          bind > swap-pane -D       # swap current pane with the next one
          bind < swap-pane -U       # swap current pane with the previous one

          # pane resizing
          bind -r H resize-pane -L 2
          bind -r J resize-pane -D 2
          bind -r K resize-pane -U 2
          bind -r L resize-pane -R 2

          # window navigation
          unbind n
          unbind p
          bind -r C-h previous-window # select previous window
          bind -r C-l next-window     # select next window
          bind Tab last-window        # move to last active window


          # replace C-b by C-a instead of using both prefixes
          set -gu prefix2
          unbind C-a
          unbind C-b
          set -g prefix C-b
          bind C-b send-prefix
        '';
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

      # Fix from https://github.com/nix-community/home-manager/issues/2942#issuecomment-1119760100
      # This belongs in global.nix but doesn't seem to work.
      # nixpkgs.config.allowUnfree = true;
      # nixpkgs.config.allowUnfreePredicate = _: true;

      # TODO: Move into a packages module
      home.packages = with pkgs;
        (
          if config.cfg.os.name == "nixos"
          then [
            # parted # filesystems
            # nettools # networking
            # openvpn # networking
            # killall # processes
            # lshw # system info
          ]
          else if config.cfg.os.name == "macos"
          then [
          ]
          else []
        )
        ++ [
          awscli2
          bashInteractive
          bat
          chezmoi # for now
          curl
          delta
          eks-node-viewer
          fd
          kubectx
          devbox
          git
          gh
          gnugrep
          jq
          k9s # Doesn't resolve properly on mac, using brew instead, see https://github.com/derailed/k9s/issues/780
          less
          nixfmt
          ripgrep
          tree
          watch
          wget
          # Below are imports from homebrew
          autoconf
          automake
          coreutils
          git-crypt
          git-lfs
          git-secret
          gnused
          gnutar
          go
          gzip
          kubernetes-helm
          helmfile
          htop
          terragrunt
          httperf
          hub
          iftop
          ipcalc
          jq
          tree
          kops
          kubectl
          kustomize
          mas
          maven
          moreutils
          ncdu
          nmap
          terraform
          wakeonlan
          yq
          # Work
          argocd
          colima
          docker
          jfrog-cli
          minikube
          yarn
          hashcat
          hugo
          kind
          iperf
          python3
        ]
        ++ [
          cmatrix
          cowsay
          figlet
          lolcat
          pipes
          toilet
          pywal
          colorz
        ];
    };
  };
}
