{
  lib,
  user,
  system,
  config,
  ...
}:
let
  inherit (lib) mkDefault;
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
      ".personal_gitconfig".source = ../templates/gitconfig/personal.tmpl;
      ".work_gitconfig".source = ../templates/gitconfig/work.tmpl;
      ".work_gitconfig_managed".source = ../templates/gitconfig/work_managed.tmpl;
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
        item = "Renovate Private Key"
        vault = "Private"

        [[ssh-keys]]
        item = "Proxmox VM SSH Key"
        vault = "Private"

        [[ssh-keys]]
        item = "Hetzner"
        vault = "Private"
      '';

      # Resolves the git SSH signing key for the current identity live from the
      # 1Password agent. Invoked by git via gpg.ssh.defaultKeyCommand, which runs
      # this as argv (no shell), so all logic lives in this script. The agent is
      # reached through SSH_AUTH_SOCK (exported by the shell).
      ".local/bin/1pw-sign" = {
        text = ''
          #!/bin/sh
          case "$1" in
            personal)     c="Personal Git Signing" ;;
            work|managed) c="Cisco Git Signing Key" ;;
            *)            c="Personal Git Signing" ;;
          esac
          ssh-add -L 2>/dev/null | grep -F "$c" | head -1
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
