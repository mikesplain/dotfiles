{
  description = "Mike Splain's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/051da568320af663533b070b3affe2b775114752"; # TODO: Unpin once resolved (https://github.com/NixOS/nixpkgs/issues/509248)

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
                direnv = prev.direnv.overrideAttrs (old: {
                  # Temporary workaround for nixpkgs-unstable while it is still
                  # behind the upstream direnv Darwin fix:
                  # - https://github.com/NixOS/nixpkgs/issues/502464
                  # - https://github.com/NixOS/nixpkgs/pull/502769
                  postPatch = (old.postPatch or "") + ''
                    if grep -q " -linkmode=external" GNUmakefile; then
                      substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
                    fi
                  '';
                });
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
