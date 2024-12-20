{ lib, user, system, config, ... }: let
  inherit (lib) mkDefault;
in {
  programs.home-manager.enable = true;
  home = {
    username = "${user.name}";
    homeDirectory = mkDefault "/home/${user.name}";
    # https://nixos.org/manual/nixos/unstable/release-notes.html
    stateVersion = "24.05";

    sessionVariables = {
        PAGER = "less";
        CLICOLOR = 1;
        EDITOR = "nvim";
    };

    file = {
      ".config/ghostty/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/chezmoi/home/dot_config/ghostty/config";
      };
    };
  };
  imports = [
    ./shell
    ./tmux
    ./programs
    ./git
    # ./packages
    # ./other.nix
  ];
}