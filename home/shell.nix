{ pkgs, ... }:
{
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
      TERM = "xterm-256color";
      LESS = "-R";
    };

    #ADD .TOOLVERSIONS SYSTEM TO THIS FILE!!!

    initContent = ''
      eval $(/run/current-system/sw/bin/brew shellenv)
      PATH="$(brew --prefix)/opt/python@3.14/libexec/bin:$PATH"

      # Explicitly set LESS variable
      export LESS="-R"

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

      # Flip k9s nodeShell flags to true across stored cluster configs
      enable_k9s_node_shell() {
        local cluster_dir="$HOME/Library/Application Support/k9s/clusters"
        if [[ ! -d "$cluster_dir" ]]; then
          echo "k9s cluster directory not found: $cluster_dir" >&2
          return 1
        fi

        local -i updates=0
        while IFS= read -r -d $'\0' file; do
          # Skip binary files to avoid mangling them
          if LC_ALL=C grep -qI "" "$file" && LC_ALL=C grep -q "nodeShell:[[:space:]]*false" "$file"; then
            local tmp_file
            if tmp_file=$(mktemp); then
              if LC_ALL=C sed -E 's/nodeShell:[[:space:]]*false/nodeShell: true/g' "$file" > "$tmp_file"; then
                if cat "$tmp_file" > "$file"; then
                  printf 'Updated %s\n' "$file"
                  updates=$((updates + 1))
                else
                  printf 'Failed to write %s\n' "$file" >&2
                fi
              else
                printf 'Failed to update %s\n' "$file" >&2
              fi
              rm -f "$tmp_file"
            else
              printf 'Failed to create temp file for %s\n' "$file" >&2
            fi
          fi
        done < <(find "$cluster_dir" -type f -print0)

        if [[ $updates -eq 0 ]]; then
          printf 'No nodeShell flags needed changes in %s\n' "$cluster_dir"
        else
          printf 'Updated %d file(s)\n' "$updates"
        fi
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
    defaultOptions = [ "-m --bind ctrl-a:select-all,ctrl-d:deselect-all" ];
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
