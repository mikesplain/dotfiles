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
    resolvedRunGitHooks = inputs.git-hooks-nix.lib.runGitHooks;
    # DEBUG: Print available attributes in git-hooks-nix.lib
    debugGitHooksLib = builtins.attrNames inputs.git-hooks-nix.lib;
  in
  {
    default = pkgs.mkShell {
      name = "dotfiles-shell-from-devshell"; # Renamed for clarity
      # Note: self.darwinConfigurations... needs to be inputs.self.darwinConfigurations... if self is part of inputs
      # Or, if darwinConfigurations is passed separately, adjust accordingly.
      # Assuming 'self' is part of 'inputs' passed to this file.
      inputsFrom = [ inputs.self.darwinConfigurations."MSPLAIN-M-CH4Y".config.system.build.toplevel ];
      buildInputs = [
        pkgs.hello # A simple package to test the shell
        # Add other development tools here
      ];
      shellHook = ''
        echo "Entered dotfiles dev shell (from devshell.nix)."
        echo "DEBUG: git-hooks-nix.lib attributes: ${builtins.concatStringsSep ", " debugGitHooksLib}"
      '';
    };
  })
