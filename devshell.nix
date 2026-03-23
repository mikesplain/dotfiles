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
        ];
      };
      fakeDotnetSdk = pkgs.runCommand "fake-dotnet-sdk" { } ''
        mkdir -p "$out/share/dotnet"
      '';
      preCommitNoDotnet = pkgs.pre-commit.override {
        # Keep nixpkgs' pre-commit package as-is, but replace the heavyweight
        # .NET SDK test runtime with a tiny stub because this repo never uses
        # the disabled dotnet hook tests.
        dotnet-sdk = fakeDotnetSdk;
      };
      pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
        src = ./.;
        package = preCommitNoDotnet;
        hooks = {
          nixfmt = {
            enable = true;
            description = "Format nix files using nixfmt";
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
          pkgs.nixfmt # For nix formatting
          pkgs.nodePackages.prettier # For general formatting
        ]
        ++ pre-commit-check.enabledPackages;

        shellHook = ''
          echo "flake.lock" > .prettierignore
          ${pre-commit-check.shellHook}
        '';
      };
    }
  );
}
