{ config, pkgs, pwnvim, nixpkgs, ... }: {
  imports = [ ./modules.nix ];
  cfg.os.version = "23.11";
  cfg.os.hostname = "SNS005454";
  nix.maxJobs = 10;
  nixpkgs.hostPlatform = "aarch64-darwin";
  cfg.user.name = "mike.splain";
  cfg.user.email = "mike.splain@sonos.com";
}
