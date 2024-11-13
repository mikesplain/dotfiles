{
  description = "Example Darwin system flake";

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

    # Fixes for x86
    # pwnvim.url = "github:zmre/pwnvim";
    pwnvim.url = "github:mikesplain/pwnvim";

    nix-homebrew = {
      # For https://github.com/zhaofengli/nix-homebrew/issues/22
      url = "github:zhaofengli/nix-homebrew";
      # url = "github:zhaofengli/nix-homebrew/brew-4.3.1";
      # url = "github:mikesplain/nix-homebrew/brew_4.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
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
    mikesplain-homebrew-tap = {
      url = "github:mikesplain/homebrew-tap";
      flake = false;
    };
    # homebrew-sk8s = {
    #   url = "git+file:///Users/mike.splain/developer/homebrew-pdsw-devops";
    #   flake = false;
    # };
    # kickstart-nix-nvim = {
    #   url = "github:nix-community/kickstart-nix.nvim";
    # };
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
    mkUser = username: {
      name = username;
      # timeZone = "Asia/Jakarta";
      # locale = "en_GB.UTF-8";
    };

    configuration = {
      nix = {
        nix.settings = {experimental-features = "nix-command flakes";};
        nixpkgs = {
          config = {allowUnfree = true;};
          overlays = [
            nur.overlay
            (final: prev: {
              pwnvim = inputs.pwnvim.packages.${final.system}.pwnvim;
            })
          ];
        };
      };

      environment.systemPackages = with nixpkgs; [
        zoxide
        inputs.pwnvim.packages."${final.system}".default
      ];

      system = {
        system,
        hostName,
        osVersion,
        username,
      }: let
        user = mkUser username;
        inherit (nixpkgs.lib.strings) hasInfix;
        platform = {
          isDarwin = hasInfix "darwin" system;
          isLinux = hasInfix "linux" system;
          isx86_64 = hasInfix "x86_64" system;
          isArm = hasInfix "aarch64" system;
        };
        homeManagerConfig = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";
          extraSpecialArgs = {inherit inputs pwnvim; user = mkUser username;};
          users.${username} = {imports = [./home];};
        };
        modules =
          if platform.isDarwin
          then [
            configuration.nix
            ./platforms/darwin/configuration.nix
            ./modules
            home-manager.darwinModules.home-manager
            {
              users.users.${user.name}.home = "/Users/${user.name}";
              home-manager = homeManagerConfig;
            }
          ]
          else [
            # configuration.nix
            # ./platforms/linux/configuration.nix
            # ./hosts/${hostName}/hardware-configuration.nix
            # ./modules
            # home-manager.nixosModules.home-manager {
            #   home-manager = configuration.homeManager;
            # }
          ];
        specialArgs = {inherit inputs hostName osVersion platform system user;};
      in
        if platform.isDarwin
        then
          nix-darwin.lib.darwinSystem {
            inherit system modules specialArgs;
          }
        else
          nixpkgs.lib.nixosSystem {
            inherit system modules specialArgs;
          };
    };
    # # Source: https://github.com/computercam/_unixconf_nix/blob/master/flake.nix
    # globalModules = [
    #   {
    #     system.configurationRevision = self.rev or self.dirtyRev or null;
    #     nixpkgs.config.allowUnfree = true;
    #     services.nix-daemon.enable = true;
    #   }
    #   ./modules/global/global.nix
    # ];
    # # globalModulesNixos = globalModules ++ [
    # #   ./modules/global/nixos.nix
    # #   home-manager.nixosModules.default
    # #   agenix.nixosModules.default
    # # ];
    # globalModulesMacos = globalModules ++ [
    #   ./modules/global/macos.nix
    #   home-manager.darwinModules.home-manager
    #   # home-manager.darwinModules.default
    #   # ./modules/common/nix-homebrew.nix
    #   # nix-homebrew.darwinModules.nix-homebrew
    #   # {
    #   # nix-homebrew = {
    #   #   # inherit user;
    #   #     enable = true;
    #   #     user = "mike.splain";
    #   #     taps = {
    #   #       "homebrew/homebrew-core" = homebrew-core;
    #   #       "homebrew/homebrew-cask" = homebrew-cask;
    #   #       "homebrew/homebrew-bundle" = homebrew-bundle;
    #   #     };
    #   #     mutableTaps = false;
    #   #     autoMigrate = true;
    #   # };
    #   # }
    #   # agenix.darwinModules.default
    # ];
  in {
    darwinConfigurations = {
      SNS005454 = configuration.system {
        system = "aarch64-darwin";
        hostName = "SNS005454";
        osVersion = "14";
        username = "mike.splain";
      };
      defaultHostname = configuration.system {
        system = "defaultSystem";
        hostName = "defaultHostname";
        osVersion = "defaultVersion";
        username = "root";
      };

      Mikes-MBP-16 = configuration.system {
        system = "x86_64-darwin";
        hostName = "Mikes-MBP-16";
        osVersion = "14";
        username = "mike";
      };

      # SNS005454 = nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   specialArgs = { inherit inputs; };
      #   pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
      #   modules = globalModulesMacos
      #     ++ [ ./hosts/SNS005454/configuration.nix ];
      # };
      # Mikes-MBP-16 = nix-darwin.lib.darwinSystem {
      #   system = "x86_64-darwin";
      #   specialArgs = { inherit inputs; };
      #   pkgs = import nixpkgs { system = "x86_64-darwin"; config.allowUnfree = true; };
      #   modules = globalModulesMacos
      #     ++ [ ./hosts/Mikes-MBP-16/configuration.nix ];
      # };
      # default = nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   specialArgs = { inherit inputs; };
      #   pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
      #   modules = globalModulesMacos
      #     ++ [ ./hosts/default/configuration.nix ];
      # };

      # silicontundra = nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   modules = globalModulesMacos
      #     ++ [ ./hosts/silicontundra/configuration.nix ];
      # };
    };
  };
}
