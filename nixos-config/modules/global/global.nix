{ config, lib, pkgs, pwnvim, ... }:
with lib;
{
  imports = [ ./options.nix ];
  # TODO: Add AGE keys here?
  # age.identityPaths = [ ../../_/id_rsa ];
  environment.systemPackages = with pkgs; [ nixfmt git age ];
  environment.variables.LANG = config.cfg.localization.lang;
  networking.hostName = config.cfg.os.hostname;
  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = "nix-command flakes";
  # These don't work here so I've moved them to home.nix
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnfreePredicate = _: true;
  programs.zsh.enable = true;
  time.timeZone = config.cfg.localization.timezone;

  # nix.settings.allowed-users = [ config.cfg.user.name ];
  nix.settings.trusted-users = [ config.cfg.user.name ];

  users.users."${config.cfg.user.name}" = (mkMerge [
    (if config.cfg.os.name == "nixos" then {
      createHome = true;
      extraGroups = [ "wheel" ];
      group = config.cfg.user.name;
      home = "/home/${config.cfg.user.name}";
      isNormalUser = true;
    } else {})
    ( if config.cfg.os.name == "macos" then {
      home = "/Users/${config.cfg.user.name}";
    } else {})
    ({
      name = config.cfg.user.name;
      shell = pkgs.zsh;
    })
  ]);

  users.groups."${config.cfg.user.name}" = (mkMerge [
    (if config.cfg.os.name == "nixos" then {
      name = config.cfg.user.name;
    } else {})
    (if config.cfg.os.name == "macos" then {
      name = "staff";
    } else {})
  ]);
}
