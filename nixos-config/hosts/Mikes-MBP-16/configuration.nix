{ config, pkgs, pwnvim, nixpkgs, ... }: {
  imports = [ ./modules.nix ];
  cfg.os.version = "23.11";
  cfg.os.hostname = "Mikes-MBP-16";
  nix.maxJobs = 10;
  nixpkgs.hostPlatform = "x86_64-darwin";
  cfg.user.name = "mike";
  cfg.user.email = "mike.splain@gmail.com";
}
