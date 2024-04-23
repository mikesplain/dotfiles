{ config, pkgs, pwnvim, nixpkgs, ... }: {
  imports = [ ./modules.nix ];
  cfg.os.version = "23.11";
  cfg.os.hostname = "default";
  nix.maxJobs = 10;
  nixpkgs.hostPlatform = "aarch64-darwin";
  cfg.user.name = "mike.splain";
  cfg.user.email = "mike.splain@gmail.com";
}
