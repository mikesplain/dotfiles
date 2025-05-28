{ inputs }:

let
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
in
forAllSystems (system:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      (final: prev: {
        pwnvim = inputs.pwnvim.packages.${system}.pwnvim;
      })
    ];
  };
  pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
    src = ./.;
    hooks = {
      nixpkgs-fmt = {
        enable = true;
        description = "Format nix files using nixpkgs-fmt";
      };
      prettier = {
        enable = true;
        description = "Format various files using prettier";
      };
    };
  };
in
{
  default = pkgs.mkShell {
    name = "dotfiles-shell-from-devshell";
    inputsFrom = [ inputs.self.darwinConfigurations."MSPLAIN-M-CH4Y".config.system.build.toplevel ];
    buildInputs = [
      pkgs.hello
      pkgs.nixpkgs-fmt # For nix formatting
      pkgs.nodePackages.prettier # For general formatting
      pkgs.convco # For conventional commits
    ] ++ pre-commit-check.enabledPackages;

    inherit (pre-commit-check) shellHook;
  };
})
