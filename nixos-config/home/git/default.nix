{ pkgs, ... }: {
  programs.git = {
    enable = true;
    # TODO: configure git with nix
    # userName = config.cfg.user.name;
    # userEmail = config.cfg.user.email;
  };
}