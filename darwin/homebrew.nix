{
  inputs,
  lib,
  pkgs,
  user,
  osVersion,
  platform,
  ...
}:
let
  inherit (inputs)
    homebrew-brew
    homebrew-cask
    homebrew-core
    jundot-omlx
    modem-homebrew-tap
    nix-homebrew
    ;
  # Temporary override until jundot/omlx's Homebrew formula catches up with
  # the latest release. Remove this and point the tap back at `jundot-omlx`
  # once upstream's Formula/omlx.rb ships the same version.
  omlxVersion = "0.3.11";
  patchedJundotOmlx = pkgs.runCommand "jundot-homebrew-omlx-${omlxVersion}" { } ''
    mkdir -p "$out"
    cp -R ${jundot-omlx}/. "$out"
    chmod -R u+w "$out"
    substituteInPlace "$out/Formula/omlx.rb" \
      --replace-fail 'url "https://github.com/jundot/omlx/archive/refs/tags/v0.3.10.tar.gz"' \
                     'url "https://github.com/jundot/omlx/archive/refs/tags/v${omlxVersion}.tar.gz"' \
      --replace-fail 'sha256 "59165b90fdb53cdff6c6b9f36f4a372700f2c259181d7ee4953f4f00b5d1f554"' \
                     'sha256 "51a109052403ce6daf975bb0657b0656ad53f20cd3c9700beac1fefcfe6dc372"'
  '';
in
{
  # Import the nix-homebrew module
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  homebrew = {
    enable = true;
    onActivation = {
      # Avoid Homebrew self-updating on every rebuild while still allowing
      # managed formula and cask upgrades during activation.
      autoUpdate = false;
      upgrade = true;
    };
    brews = [
      "awscli"
      "gh"
      "gitui"
      "hashcat"
      "hcxtools"
      "ipcalc"
      "jundot/omlx/omlx"
      "k9s"
      "logdy"
      "mactop"
      "mise"
      "modem-dev/tap/hunk"
      "node"
      "ncdu"
      "opencode"
      "pi-coding-agent"
      "python"
      "ripgrep"
      "terraform-ls"
      "telnet"
      "usage"
    ];
    casks =
      (if osVersion >= "14" then [ "thaw" ] else [ ])
      ++
      # Remove lm-studio since it can be flakey in CI.
      # (if platform.isArm then [ "lm-studio" ] else []) ++
      [
        "1password-cli"
        "1password"
        "appcleaner"
        "disk-inventory-x"
        "claude-code"
        "codex"
        "codex-app"
        "cursor"
        "draw-things"
        "xykong/tap/flux-markdown"
        "linearmouse"
        #"docker-desktop"
        "elgato-stream-deck"
        "ghostty"
        "google-chrome"
        "gpg-suite"
        "handy"
        "lm-studio"
        "obsidian"
        #"ollama-app"
        "raycast"
        "session-manager-plugin"
        "shottr"
        "spotify"
        "stats"
        "thaw"
        "vagrant"
        "virtualbox"
        "visual-studio-code"
        "utm"
      ];

    # Mac App Store apps
    # These app IDs are from using the mas CLI app (mac app store)
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    masApps =
      if user.name != "runner" then
        {
          "GoodLinks" = 1474335294;
          "TestFlight" = 899247664;
          "The Unarchiver" = 425424353;
          "Things" = 904280696;
          "Velja" = 1607635845;
          "WireGuard" = 1451685025;
        }
      else
        { };
  };

  # Nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    package = homebrew-brew // {
      name = "brew-${homebrew-brew.shortRev}";
      version = homebrew-brew.shortRev;
    };
    user = user.name;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "hashicorp/tap" = inputs.hashicorp-tap;
      "jundot/homebrew-omlx" = patchedJundotOmlx;
      "modem-dev/tap" = modem-homebrew-tap;
      "xykong/tap" = inputs.xykong-tap;
    };
    mutableTaps = true;
    autoMigrate = true;
  };
}
