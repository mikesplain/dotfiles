{
  description = "Mike Splain's macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
    pwnvim.url = "github:mikesplain/pwnvim";

    # Homebrew inputs
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nur,
    pwnvim,
    ...
  }: let
    # Helper function to create user
    mkUser = username: {name = username;};

    # Creates a Darwin configuration with the given parameters
    mkDarwinSystem = {
      system,
      hostname,
      osVersion,
      username,
    }: let
      user = mkUser username;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlays.default
          (final: prev: {
            pwnvim = inputs.pwnvim.packages.${system}.pwnvim;
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
        specialArgs = {inherit inputs hostname osVersion platform system user pkgs;};
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
                inherit inputs hostname pwnvim platform;
                user = user;
              };
              users.${username} = {imports = [./home];};
            };

            # Set home directory correctly for macOS
            users.users.${user.name}.home = "/Users/${user.name}";
          }
        ];
      };
  in {
    darwinConfigurations = {
      "MSPLAIN-M-CH4Y" = mkDarwinSystem {
        system = "aarch64-darwin";
        hostname = "MSPLAIN-M-CH4Y";
        osVersion = "14";
        username = "msplain";
      };

      "Mikes-MBP-16" = mkDarwinSystem {
        system = "x86_64-darwin";
        hostname = "Mikes-MBP-16";
        osVersion = "14";
        username = "mike";
      };

      # For CI and testing
      "defaultHostname" = mkDarwinSystem {
        system = "defaultSystem";
        hostname = "defaultHostname";
        osVersion = "defaultVersion";
        username = "runner";
      };
    };
  };
}
