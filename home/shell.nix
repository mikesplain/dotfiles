{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    shellAliases = {
      ls = "eza -g";
      l = "eza -la";
      la = "l";
      ll = "l";
      cp = "cp -rv";
      mkdir = "mkdir -vp";
      df = "df -H";
      rm = "rm -iv";
      mv = "mv -iv";
      k = "kubectl";
      x = "kubectx";
      kx = "kubectx";
      kns = "kubens";
      ktmux = "tmux new-session -d 'watch kubectl get nodes -L kops.k8s.io/instancegroup,node.kubernetes.io/instance-type' && tmux split-window -h 'watch kubectl get pods --all-namespaces --sort-by {.metadata.namespace}' && tmux split-window -v -t 1 && tmux -2 attach-session -d";
      clear_dns_cache = "dscacheutil -flushcache && sudo killall -HUP mDNSResponder";
      gut = "git";
      cat = "bat";
      grep = "grep --color=auto";
      sf = "sk8s find";
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
      "......." = "../../../../../..";
      "cd ..." = "../..";
      "cd ...." = "../../..";
      "cd ....." = "../../../..";
      "cd ......" = "../../../../..";
      "cd ......." = "../../../../../..";
      "dot" = "cd $HOME/.dotfiles";
      "dotfiles" = "dot";
      w = "windsurf .";
    };

    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

    #ADD .TOOLVERSIONS SYSTEM TO THIS FILE!!!

    initContent = ''
      eval $(/run/current-system/sw/bin/brew shellenv)
      PATH="$(brew --prefix)/opt/python@3.13/libexec/bin:$PATH"

      autoload -U select-word-style
      select-word-style bash

      # Better key bindings for terminal navigation
      bindkey "\e[1;3D" backward-word     # ⌥←
      bindkey "\e[1;3C" forward-word      # ⌥→
      bindkey "^[[1;9D" beginning-of-line # cmd+←
      bindkey "^[[1;9C" end-of-line       # cmd+→
      bindkey "^[[3~" delete-char         # delete key
      bindkey "^[[3;3~" delete-word        # delete key

      export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

      eval "$(mise activate zsh)"

      # Switch to the current flake
      switch() {
        sudo darwin-rebuild switch --flake .
      }

      # Cisco Specific Stuff
      [[ -f $HOME/.zshrc-cisco ]] && source $HOME/.zshrc-cisco

      # Clear the screen and scrollback buffer
      function clear-screen-and-scrollback() {
        builtin echoti civis >"$TTY"
        builtin print -rn -- $'\e[H\e[2J' >"$TTY"
        builtin zle .reset-prompt
        builtin zle -R
        builtin print -rn -- $'\e[3J' >"$TTY"
        builtin echoti cnorm >"$TTY"
      }
      zle -N clear-screen-and-scrollback
      bindkey '^L' clear-screen-and-scrollback

    '';
  };

  # Add other CLI tools
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow";
    defaultOptions = ["-m --bind ctrl-a:select-all,ctrl-d:deselect-all"];
  };

  programs.eza.enable = true;
  programs.bash.enable = true;
  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      kubernetes = {
        disabled = false;
        contexts = [
          {
            context_pattern = "arn:aws:eks:(?P<region>[\\w-]+):.*\\/(?P<cluster>[\\w-]+)";
            context_alias = "eks/$region/$cluster";
          }
        ];
      };
    };
  };
}