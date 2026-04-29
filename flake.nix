{
  description = "Mike Splain's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    hashicorp-tap = {
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-brew = {
      url = "github:Homebrew/brew";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    xykong-tap = {
      url = "github:xykong/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      git-hooks-nix,
      nix-darwin,
      home-manager,
      nur,
      ...
    }:
    let
      # Import forAllSystems from devshell.nix
      inherit (import ./devshell.nix { inherit inputs; }) forAllSystems;

      # Helper function to create user
      mkUser = username: { name = username; };

      # Creates a Darwin configuration with the given parameters
      mkDarwinSystem =
        {
          system,
          osVersion,
          username,
        }:
        let
          user = mkUser username;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              nur.overlays.default
              (final: prev: {
                direnv =
                  if prev.stdenv.isDarwin then
                    prev.direnv.overrideAttrs (_old: {
                      # Temporary Darwin workaround for flaky shell integration
                      # checks while nixpkgs tracks the fish/zsh failures:
                      # https://github.com/NixOS/nixpkgs/issues/507531
                      nativeCheckInputs = [ prev.writableTmpDirAsHomeHook ];
                      checkPhase = ''
                        runHook preCheck

                        make test-go test-bash

                        runHook postCheck
                      '';
                    })
                  else
                    prev.direnv;
              })
              (final: prev: {
                vscode-lldb-adapter =
                  if prev.stdenv.isDarwin && prev.stdenv.isx86_64 then
                    prev.vscode-lldb-adapter.override {
                      llvmPackages = prev.llvmPackages_18;
                    }
                  else
                    prev.vscode-lldb-adapter;
              })
            ];
          };

          # Platform detection
          platform = {
            isDarwin = nixpkgs.lib.strings.hasInfix "darwin" system;
            isLinux = nixpkgs.lib.strings.hasInfix "linux" system;
            isx86_64 = nixpkgs.lib.strings.hasInfix "x86_64" system;
            isArm = nixpkgs.lib.strings.hasInfix "aarch64" system;
          };
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              osVersion
              platform
              system
              user
              pkgs
              ;
          };
          modules = [
            # Core system config
            ./darwin

            # Home Manager module
            home-manager.darwinModules.home-manager
            {
              nixpkgs.pkgs = pkgs;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = {
                  inherit
                    inputs
                    platform
                    ;
                  user = user;
                };
                users.${username} = {
                  imports = [ ./home ];
                };
              };

              # Set home directory correctly for macOS
              users.users.${user.name}.home = "/Users/${user.name}";
            }
          ];
        };

      publicDarwinConfigurations = {
        personal-darwin-arm64 = mkDarwinSystem {
          system = "aarch64-darwin";
          osVersion = "26";
          username = "mike";
        };
        darwin-arm64 = mkDarwinSystem {
          system = "aarch64-darwin";
          osVersion = "26";
          username = "msplain";
        };

        darwin-x86_64 = mkDarwinSystem {
          system = "x86_64-darwin";
          osVersion = "26";
          username = "mike";
        };

        # For CI and testing
        ci = mkDarwinSystem {
          system = "defaultSystem";
          osVersion = "defaultVersion";
          username = "runner";
        };
      };
    in
    {
      darwinConfigurations = publicDarwinConfigurations;

      # Import devShells from devshell.nix
      inherit (import ./devshell.nix { inherit inputs; }) devShells;
    };
}
