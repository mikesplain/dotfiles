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
      preCommitNoDotnet = pkgs.pre-commit.overridePythonAttrs (old: {
        # nixpkgs packages extra hook-language test runtimes into pre-commit.
        # We don't use .NET hooks in this repo, so trim that test-only input.
        doCheck = false;
        preCheck = "";
        postCheck = "";
        nativeCheckInputs = pkgs.lib.filter (
          pkg: (pkgs.lib.getName pkg) != "dotnet-sdk"
        ) old.nativeCheckInputs;
      });
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
