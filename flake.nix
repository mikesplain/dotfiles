{
  description = "Mike Splain's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # Temporary: pin only pam-watchid to the last cached revision so routine
    # nixpkgs updates do not trigger a local Swift toolchain rebuild.
    pamWatchIdNixpkgs.url = "github:NixOS/nixpkgs/e0c84f9d0ad137f076dc957494f5b39885597d4f";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    hashicorp-tap = {
      url = "github:hashicorp/homebrew-tap";
      flake = false;
    };
    mikesplain-homebrew-omlx = {
      url = "github:mikesplain/homebrew-omlx";
      flake = false;
    };
    modem-homebrew-tap = {
      url = "github:modem-dev/homebrew-tap";
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
      pamWatchIdNixpkgs,
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
          pamWatchIdPkgs = import pamWatchIdNixpkgs {
            inherit system;
          };
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              nur.overlays.default
              # Temporary: keep Apple Watch sudo authentication while reusing
              # the cached pam-watchid/Swift closure from the pinned revision.
              (_final: _prev: { pam-watchid = pamWatchIdPkgs.pam-watchid; })
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
