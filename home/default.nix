{
  lib,
  user,
  system,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
  gitIdentityConfig =
    template:
    lib.replaceStrings [ "@1PW_SIGN@" ] [ "${config.home.homeDirectory}/.local/bin/1pw-sign" ] (
      builtins.readFile template
    );
in
{
  programs.home-manager.enable = true;

  home = {
    username = "${user.name}";
    homeDirectory = mkDefault "/home/${user.name}";
    stateVersion = "24.05";

    sessionVariables = {
      PAGER = "less";
      LESS = "-R";
      CLICOLOR = 1;
      EDITOR = "nvim";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];

    file = {
      ".personal_gitconfig".text = gitIdentityConfig ../templates/gitconfig/personal.tmpl;
      ".work_gitconfig".text = gitIdentityConfig ../templates/gitconfig/work.tmpl;
      ".work_gitconfig_managed".text = gitIdentityConfig ../templates/gitconfig/work_managed.tmpl;
      "Library/Application Support/k9s/config.yaml".source = ../templates/k9s.config.yaml;
      "Library/Application Support/k9s/hotkeys.yaml".source = ../templates/k9s.hotkeys.yaml;

      # Expose authentication and signing keys through the 1Password agent.
      # SSH Bookmarks select one authentication key for each GitHub host alias;
      # key order alone cannot select the correct GitHub account. Item names keep
      # agent discovery independent of key fingerprints.
      ".config/1Password/ssh/agent.toml".text = ''
        # 1Password SSH agent configuration.
        #
        # Git auth keys are available to the SSH Bookmarks host mappings.
        # Order: [git auth] then [git signing] then [other keys].

        # --- GitHub auth (offer first) ---
        [[ssh-keys]]
        item = "Github - Personal"
        vault = "Private"

        [[ssh-keys]]
        item = "Cisco SSH"
        vault = "Private"

        [[ssh-keys]]
        item = "Cisco Managed Github SSH"
        vault = "Private"

        # --- Git signing (resolved by gpg.ssh.defaultKeyCommand / 1pw-sign) ---
        [[ssh-keys]]
        item = "Personal Git Signing"
        vault = "Private"

        [[ssh-keys]]
        item = "Cisco Git Signing Key"
        vault = "Private"

        # --- Other SSH keys ---
        [[ssh-keys]]
        item = "Personal SSH Key"
        vault = "Private"

        [[ssh-keys]]
        item = "Proxmox VM SSH Key"
        vault = "Private"

      '';

      # Resolves the git SSH signing key for the current identity live from the
      # 1Password agent. Use an explicit socket and executable paths so signing
      # also works in GUI clients that do not inherit the interactive shell.
      ".local/bin/1pw-sign" = {
        text = ''
          #!/bin/sh
          if [ "$#" -ne 1 ]; then
            echo "Usage: 1pw-sign personal|work|managed" >&2
            exit 2
          fi
          case "$1" in
            personal)     comment="Personal Git Signing" ;;
            work|managed) comment="Cisco Git Signing Key" ;;
            *) echo "1pw-sign: unknown identity: $1" >&2; exit 2 ;;
          esac

          export SSH_AUTH_SOCK="$HOME${
            if pkgs.stdenv.isDarwin then
              "/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else
              "/.1password/agent.sock"
          }"
          if [ ! -S "$SSH_AUTH_SOCK" ]; then
            echo "1pw-sign: 1Password SSH agent socket is unavailable: $SSH_AUTH_SOCK" >&2
            exit 1
          fi
          if ! keys=$(${pkgs.openssh}/bin/ssh-add -L); then
            echo "1pw-sign: could not read keys from the 1Password SSH agent" >&2
            exit 1
          fi

          printf '%s\n' "$keys" | ${pkgs.gawk}/bin/awk -v comment="$comment" '
            {
              title = $0
              sub(/^[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]*/, "", title)
              if (title == comment) {
                key = $0
                matches++
              }
            }
            END {
              if (matches == 1) {
                print key
              } else {
                printf "1pw-sign: expected one key named \"%s\"; found %d\n", comment, matches > "/dev/stderr"
                exit 1
              }
            }
          '
        '';
        executable = true;
      };
    };
  };

  imports = [
    ./shell.nix
    ./tmux.nix
    ./programs.nix
    ./git.nix
    ./neovim.nix
  ];
}
