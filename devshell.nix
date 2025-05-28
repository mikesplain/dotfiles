{ nixpkgs, nur, pwnvim }:
let
  forAllSystems = nixpkgs.lib.genAttrs [
    "aarch64-darwin"
    "x86_64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
in
forAllSystems (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        nur.overlays.default
        (final: prev: {
          pwnvim = pwnvim.packages.${system}.pwnvim;
        })
      ];
    };
  in
  {
    default = pkgs.mkShell {
      name = "dotfiles-shell";
      buildInputs = [
        pkgs.hello # A simple package to test the shell
        # Add other development tools here
      ];
      shellHook = ''
        echo "Entered dotfiles dev shell."
      '';
    };
  })
