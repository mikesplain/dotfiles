{
  config,
  lib,
  pkgs,
  options,
  pwnvim,
  nixpkgs,
  inputs,
  ...
}:
with pkgs.stdenv;
with lib; let
  # fzshInitExtraConfig = import ./zshInitExtraConfig.nix;
  # zshInitExtraConfig = fzshInitExtraConfig { lib = lib; pkgs = pkgs; };
  # fgetZshInitExtra = import ./getZshInitExtra.nix;
  # getZshInitExtra = fgetZshInitExtra { lib = lib; pkgs= pkgs; zshInitExtraConfig = zshInitExtraConfig; };
in {
  nixpkgs.overlays = [
    (final: prev: {
      pwnvim = inputs.pwnvim.packages."${system}".pwnvim;
    })
  ];

  environment.systemPackages = with pkgs; [
    zoxide
    inputs.pwnvim.packages."${system}".default
  ];
}