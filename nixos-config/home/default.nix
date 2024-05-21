{ lib, user, system, ... }: let
  inherit (lib) mkDefault;
in {
  programs.home-manager.enable = true;
  home = {
    username = "${user.name}";
    homeDirectory = mkDefault "/home/${user.name}";
    stateVersion = "23.11";

    sessionVariables = {
        PAGER = "less";
        CLICOLOR = 1;
        EDITOR = "nvim";
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