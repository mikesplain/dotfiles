_: {
  imports = [ ./nix-homebrew.nix ];
  homebrew = {
    enable = true;
    brews = [
      "aws-sso-util"
      "k9s"
      "hcxtools"
    ];
    casks = [
      "session-manager-plugin"
      "appcleaner"
    ];

    # casks = [];
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      # "1password" = 1333542190;
    };
  };
}