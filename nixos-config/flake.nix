{
  description = "Example Darwin system flake";

  inputs = {
    # Temp fix for https://github.com/NixOS/nixpkgs/pull/304277
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Fixes for x86
    # pwnvim.url = "github:zmre/pwnvim";
    pwnvim.url = "github:mikesplain/pwnvim";

    our-brew-src = {
      url = "github:Homebrew/brew/4.3.0";
      flake = false;
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.brew-src.follows = "our-brew-src";
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # kickstart-nix-nvim = {
    #   url = "github:nix-community/kickstart-nix.nvim";
    # };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    pwnvim,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    disko,
    ...
  }: let
    # Source: https://github.com/computercam/_unixconf_nix/blob/master/flake.nix
    globalModules = [
      {
        system.configurationRevision = self.rev or self.dirtyRev or null;
        nixpkgs.config.allowUnfree = true;
        services.nix-daemon.enable = true;
      }
      ./modules/global/global.nix
    ];
    # globalModulesNixos = globalModules ++ [
    #   ./modules/global/nixos.nix
    #   home-manager.nixosModules.default
    #   agenix.nixosModules.default
    # ];
    globalModulesMacos = globalModules ++ [
      ./modules/global/macos.nix
      home-manager.darwinModules.home-manager
      # home-manager.darwinModules.default
      ./modules/common/nix-homebrew.nix
      # nix-homebrew.darwinModules.nix-homebrew
      # {
      # nix-homebrew = {
      #   # inherit user;
      #     enable = true;
      #     user = "mike.splain";
      #     taps = {
      #       "homebrew/homebrew-core" = homebrew-core;
      #       "homebrew/homebrew-cask" = homebrew-cask;
      #       "homebrew/homebrew-bundle" = homebrew-bundle;
      #     };
      #     mutableTaps = false;
      #     autoMigrate = true;
      # };
      # }
      # agenix.darwinModules.default
    ];
    # # linuxSystems = ["x86_64-linux" "aarch64-linux"];
    # # darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    # # forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
    # configuration = {pkgs, ...}: {
    #   # List packages installed in system profile. To search by name, run:
    #   # $ nix-env -qaP | grep wget
    #   environment.systemPackages = [
    #     pkgs.vim
    #     pkgs.asdf-vm
    #   ];

    #   # Auto upgrade nix package and the daemon service.
    #   services.nix-daemon.enable = true;
    #   nix.package = pkgs.nix;

    #   # Necessary for using flakes on this system.
    #   nix.settings.experimental-features = "nix-command flakes";

    #   # Create /etc/zshrc that loads the nix-darwin environment.
    #   programs.zsh.enable = true; # default shell on catalina
    #   # programs.fish.enable = true;

    #   # Set Git commit hash for darwin-version.
    #   system.configurationRevision = self.rev or self.dirtyRev or null;

    #   # Used for backwards compatibility, please read the changelog before changing.
    #   # $ darwin-rebuild changelog
    #   system.stateVersion = 4;

    #   # The platform the configuration will be used on.
    #   nixpkgs.hostPlatform = "aarch64-darwin";

    #   homebrew = {
    #     enable = true;
    #     brews = [
    #       "aws-sso-util"
    #       "k9s"
    #     ];
    #     casks = [
    #       "session-manager-plugin"
    #     ];

    #     # casks = [];
    #     # These app IDs are from using the mas CLI app
    #     # mas = mac app store
    #     # https://github.com/mas-cli/mas
    #     #
    #     # $ nix shell nixpkgs#mas
    #     # $ mas search <app name>
    #     #
    #     masApps = {
    #       # "1password" = 1333542190;
    #     };
    #   };
    # };
    # hm = {pkgs, ...}: {
    #   programs.fish.enable = true;
    #   environment = {
    #     shells = with pkgs; [zsh];
    #     loginShell = pkgs.zsh;
    #     systemPackages = [pkgs.coreutils];
    #     pathsToLink = ["/Applications"];
    #   };
    #   nix.extraOptions = ''
    #     experimental-features = nix-command flakes
    #   '';
    #   users.users."mike.splain" = {
    #     home = "/Users/mike.splain";
    #     # shell = pkgs.zsh;
    #   };
    #   fonts.fontDir.enable = true;
    #   # fonts.fonts = [(pkgs.nerdfonts.override {fonts = ["Meslo"];})];
    #   fonts.fonts = [(pkgs.nerdfonts)];
    #   security.pam.enableSudoTouchIdAuth = true;
    #   services.nix-daemon.enable = true;
    #   system.defaults = {
    #     finder.AppleShowAllExtensions = true;
    #     dock.autohide = true;
    #     finder._FXShowPosixPathInTitle = true;
    #     NSGlobalDomain.AppleShowAllExtensions = true;
    #     NSGlobalDomain.InitialKeyRepeat = 14;
    #     NSGlobalDomain.KeyRepeat = 1;
    #   };
    #   system.stateVersion = 4;
    # };
  in {
    darwinConfigurations = {
      SNS005454 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
        modules = globalModulesMacos
          ++ [ ./hosts/SNS005454/configuration.nix ];
      };
      Mikes-MBP-16 = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = { inherit inputs; };
        pkgs = import nixpkgs { system = "x86_64-darwin"; config.allowUnfree = true; };
        modules = globalModulesMacos
          ++ [ ./hosts/Mikes-MBP-16/configuration.nix ];
      };
      default = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
        modules = globalModulesMacos
          ++ [ ./hosts/default/configuration.nix ];
      };
      # silicontundra = nix-darwin.lib.darwinSystem {
      #   system = "aarch64-darwin";
      #   modules = globalModulesMacos
      #     ++ [ ./hosts/silicontundra/configuration.nix ];
      # };
    };
  #   # Build darwin flake using:
  #   # $ darwin-rebuild build --flake .#mikesplains-Virtual-Machine
  #   darwinConfigurations."SNS005454" = nix-darwin.lib.darwinSystem {
  #     #Added, system arch, might not be nececssary
  #     system = "aarch64-darwin";
  #     pkgs = import nixpkgs {
  #       system = "aarch64-darwin";
  #       # Allow VSCode installer
  #       config.allowUnfree = true;
  #     };
  #     modules = [
  #       hm
  #       home-manager.darwinModules.home-manager
  #       {
  #         home-manager = {
  #           backupFileExtension = "backup";
  #           useGlobalPkgs = true;
  #           useUserPackages = true;
  #           extraSpecialArgs = {inherit pwnvim;};
  #           users."mike.splain".imports = [./modules/home-manager];
  #         };
  #       }
  #       nix-homebrew.darwinModules.nix-homebrew
  #       {
  #         nix-homebrew = {
  #           # inherit user;
  #           enable = true;
  #           user = "mike.splain";
  #           taps = {
  #             "homebrew/homebrew-core" = homebrew-core;
  #             "homebrew/homebrew-cask" = homebrew-cask;
  #             "homebrew/homebrew-bundle" = homebrew-bundle;
  #           };
  #           mutableTaps = false;
  #           autoMigrate = true;
  #         };
  #       }
  #       configuration
  #     ];
  #   };

  #   # Expose the package set, including overlays, for convenience.
  #   darwinPackages = self.darwinConfigurations."SNS005454".pkgs;
  # };
  };
}
