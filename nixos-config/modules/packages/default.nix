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
in {
  nixpkgs.overlays = [
    (final: prev: {
      pwnvim = inputs.pwnvim.packages."${system}".pwnvim;
    })
  ];

# { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      pkgs.pwnvim
      asdf-vm
      awscli2
      bashInteractive
      bat
      chezmoi # for now
      curl
      delta
      eks-node-viewer
      fd
      kubectx
      devbox
      git
      gh
      gnugrep
      jq
      k9s # Doesn't resolve properly on mac, using brew instead, see https://github.com/derailed/k9s/issues/780
      less
      nixfmt-classic
      ripgrep
      tree
      watch
      wget
      # Below are imports from homebrew
      autoconf
      automake
      coreutils
      git-crypt
      git-lfs
      git-secret
      gnused
      gnutar
      go
      gzip
      kubernetes-helm
      helmfile
      htop
      terragrunt
      httperf
      hub
      iftop
      ipcalc
      jq
      tree
      kops
      kubectl
      kustomize
      mas
      maven
      moreutils
      # Disabling due to https://github.com/NixOS/nixpkgs/issues/317055
      # ncdu
      nmap
      terraform
      wakeonlan
      yq
      # Work
      argocd
      colima
      docker
      jfrog-cli
      minikube
      yarn
      hashcat
      # hugo
      kind
      iperf
      python3
      cmatrix
      cowsay
      figlet
      lolcat
      pipes
      toilet
      pywal
      colorz
    ];
}