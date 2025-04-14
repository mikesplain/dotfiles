{
  inputs,
  pkgs,
  hostName,
  ...
}:{
  programs.git = {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.git.enable
    enable = true;
    userName = "Mike Splain";
    userEmail = (
      if hostName == "SNS005454"
        then "mike.splain@sonos.com"
        else "mike.splain@gmail.com"
    );

    aliases = {
      # Print the name of the current upstream tracking branch.
      upstream = "!git config --get branch.$(git current-branch).remote || echo origin";
      # Cherry-pick a commit with your signature.
      sign = "cherry-pick --signoff";
      # Create a pull request on GitHub using the `hub` command.
      pull-request = "!hub pull-request -o";
      # Push the current branch upstream to origin using the same branch
      # name for the remote branch.
      upstream-current-branch = "!git push --set-upstream origin $(git current-branch)";
      # Upstream the current branch to origin and create a pull request
      # on GitHub.
      upstream-and-pull-request = "!git upstream-current-branch && git pull-request";
      # Push the current branch and set it as the default upstream branch.
      push-and-set-upstream = "push --set-upstream";
      # Show the commit log with a prettier, clearer history.
      pretty-one-line-log = "log --graph --oneline --decorate";
      # Checkout the main branch and update it.
      pull-main = "!git checkout main && git pull";
      # Shortcut to above
      main = "!git pull-main";
      # Checkout the develop branch and update it.
      pull-develop = "!git checkout develop && git pull";
      # Shortcut to above
      develop = "!git pull-develop";
      # Create a new branch by checking out another branch.
	    checkout-as-new-branch = "checkout -b";
      # Print the name of the current branch.
	    current-branch = "symbolic-ref --short HEAD";

      ## Shortened 'New' Commands
      work-in-progress = "commit -a -m 'WIP'";
      wip = "!git work-in-progress";
      pr = "!git upstream-and-pull-request";
      up = "!git upstream-current-branch";
      l = "!git pretty-one-line-log || true";
      b = "!git checkout-as-new-branch";

      ## Shortened Existing Commands
      p = "pull";
      s = "status --short --branch";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
      };
    };

    ignores = [
      # Ignore temporary generated files.
      "*.rej"
      "*.swp"
      "*~"
      # Ignore thumbnails metadata generated by OSX.
      ".DS_Store"
    ];

    extraConfig = {
      github = {
        user = (
          if hostName == "SNS005454"
            then "mike.splain@sonos.com"
            else "mike.splain@gmail.com"
        );
      };
      color = {
        ui = true;
      };
      gist = {
        browse = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      fetch = {
        prune = "1";
      };
      rerere = {
        enabled = true;
      };
      core = {
        	# Don't prompt for commit messages for merge commits.
          mergeoptions = "--no-edit";
          editor = "nvim";
          # pager = "delta";
      };
      help = {
        autocorrect = 1;
      };
      diff = {
        colorMoved = "default";
      };

      merge = {
        conflictstyle = "diff3";
      };

      mergetool = {
        prompt = false;
        keepBackup = false;
        keepTemporaries = false;
      };

      apply = {
        whitespace = "fix";
      };

      rebase = {
        autosquash = true;
        autoStash = true;
      };

      hub = {
        protocol = "https";
      };

      commit = {
        verbose = true;
      };

      pull = {
        rebase = true;
      };

      # interactive = {
      #   diffFilter = "delta --color-only";
      # };

      color.diff-highlight = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };

      color.diff = {
        meta = "11";
        frag = "magenta bold";
        func = "146 bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
    };
    includes = [
      {
        condition = "gitdir:~/.local/share/chezmoi";
        path = "~/.personal_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/Sonos-Inc/**";
        path = "~/.work_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/mikesplainsonos/**";
        path = "~/.work_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/mikesplain/**";
        path = "~/.personal_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/kubernetes/**";
        path = "~/.personal_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/homebrew/**";
        path = "~/.personal_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/RobustIntelligence/**";
        path = "~/.personal_gitconfig";
      }
      {
        condition = "hasconfig:remote.*.url:https://github.com/cisco-sbg/**";
        path = "~/.personal_gitconfig";
      }
    ];
  };

  programs.gitui = {
    enable = true;
  };
}