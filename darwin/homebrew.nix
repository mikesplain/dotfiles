{
  inputs,
  lib,
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
    mikesplain-homebrew-omlx
    modem-homebrew-tap
    nix-homebrew
    ;
  brewBin = if platform.isArm then "/opt/homebrew/bin/brew" else "/usr/local/bin/brew";
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
      "k9s"
      "logdy"
      "mactop"
      "mise"
      "modem-dev/tap/hunk"
      "node"
      "ncdu"
      "opencode"
      "pi-coding-agent"
      "python@3.14"
      "ripgrep"
      "terraform-ls"
      "telnet"
      "usage"
    ];
    casks = [
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
      "mikesplain/omlx/omlx"
      "obsidian"
      "passepartout"
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
          # WireGuard removed — app has not been maintained
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
      "mikesplain/homebrew-omlx" = mikesplain-homebrew-omlx;
      "modem-dev/homebrew-tap" = modem-homebrew-tap;
      "xykong/homebrew-tap" = inputs.xykong-tap;
    };
    mutableTaps = true;
    autoMigrate = true;
  };

  system.activationScripts.homebrew.text = lib.mkOrder 600 ''
    # Trust managed non-official taps after nix-homebrew creates them and
    # before nix-darwin runs Homebrew Bundle.
    if [ -x "${brewBin}" ] && sudo --user=${lib.escapeShellArg user.name} --set-home "${brewBin}" trust --help >/dev/null 2>&1; then
      echo >&2 "Trusting Homebrew taps..."
      sudo --user=${lib.escapeShellArg user.name} --set-home "${brewBin}" trust --tap \
        hashicorp/tap \
        mikesplain/omlx \
        modem-dev/tap \
        xykong/tap
    fi
  '';
}
