{
  lib,
  user,
  system,
  config,
  hostname,
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

    file = {
      ".personal_gitconfig".source = ../templates/gitconfig/personal.tmpl;
      ".work_gitconfig".source = ../templates/gitconfig/work.tmpl;
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
