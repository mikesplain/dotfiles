{ inputs }:

rec {
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  devShells = forAllSystems (
    system:
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
          nixfmt-rfc-style = {
            enable = true;
            description = "Format nix files using nixfmt-rfc-style";
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
        buildInputs = [
          pkgs.hello
          pkgs.nixpkgs-fmt # For nix formatting
          pkgs.nodePackages.prettier # For general formatting
        ] ++ pre-commit-check.enabledPackages;

        shellHook = ''
          echo "flake.lock" > .prettierignore
          ${pre-commit-check.shellHook}
        '';
      };
    }
  );
}
