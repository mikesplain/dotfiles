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
      update_flake_from_pr = "__flake_update_merge";
      w = "windsurf .";
      c = "cursor .";
      codex = "GITHUB_PAT_TOKEN=$(gh auth token) command codex --yolo";
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

            help() {
              cat <<'EOF'
      Custom commands (.dotfiles)

      High-level
        help                    Show this list
        dot, dotfiles           cd $HOME/.dotfiles
        switch                  darwin-rebuild switch --flake .
        update_flake_from_pr    Approve + merge latest successful flake update PR and pull
        w                       windsurf .
        c                       cursor .
        clear_dns_cache         Flush macOS DNS cache

      Git
        gut                     git
        __flake_update_merge    (internal) Merge latest successful flake update PR

      Navigation
        ...                     ../..
        ....                    ../../..
        .....                   ../../../..
        ......                  ../../../../..
        .......                 ../../../../../..
        cd ...                  ../..
        cd ....                 ../../..
        cd .....                ../../../..
        cd ......               ../../../../..
        cd .......              ../../../../../..

      Listing & file ops
        ls                      eza -g
        l, la, ll               eza -la
        cat                     bat
        grep                    grep --color=auto
        cp                      cp -rv
        mv                      mv -iv
        rm                      rm -iv
        mkdir                   mkdir -vp
        df                      df -H

      Kubernetes
        k                       kubectl
        x, kx                   kubectx
        kns                     kubens
        ktmux                   tmux layout for cluster watches
        sf                      sk8s find
        enable_k9s_node_shell   Enable nodeShell in k9s configs

      Terminal
        clear-screen-and-scrollback  Clear screen + scrollback (Ctrl+L)

      Utilities (Home Manager + Flake)
        bat, coreutils, curl, delta, direnv, eza, fd, fzf, git, jq, kubectx,
        nixfmt-classic, pwnvim, ripgrep, starship, tree, wget, zoxide
      EOF
            }

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

            # Approve + merge latest successful flake update PR and pull locally.
            __flake_update_merge() {
              local workflow="flake-update.yaml"
              local repo_dir="$HOME/.dotfiles"
              local pr_arg="$1"

              if [[ ! -d "$repo_dir/.git" ]]; then
                echo "dotfiles repo not found at $repo_dir" >&2
                return 1
              fi

              if ! command -v gh >/dev/null 2>&1; then
                echo "gh CLI is not available" >&2
                return 1
              fi

              (
                cd "$repo_dir" || exit 1

                local run_fields
                if ! run_fields=$(gh run list --workflow "$workflow" --limit 1 --json status,conclusion,headBranch,url --jq 'if length == 0 then "" else .[0] | "\(.status)\t\(.conclusion)\t\(.headBranch)\t\(.url)" end'); then
                  echo "Failed to list runs for $workflow" >&2
                  exit 1
                fi
                if [[ -z "$run_fields" ]]; then
                  echo "No runs found for $workflow" >&2
                  exit 1
                fi

                local run_status run_conclusion run_branch run_url
                IFS=$'\t' read -r run_status run_conclusion run_branch run_url <<< "$run_fields"

                if [[ "$run_status" != "completed" || "$run_conclusion" != "success" ]]; then
                  echo "Latest run is not successful: $run_status/$run_conclusion ($run_url)" >&2
                  exit 1
                fi

                local default_branch
                default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
                if [[ -z "$default_branch" ]]; then
                  default_branch="main"
                fi

                local pr_fields=""
                if [[ -n "$pr_arg" ]]; then
                  if [[ "$pr_arg" == <-> ]]; then
                    if ! pr_fields=$(gh pr view "$pr_arg" --json number,url,state --jq 'select(.state == "OPEN") | "\(.number)\t\(.url)"'); then
                      echo "Failed to read PR $pr_arg" >&2
                      exit 1
                    fi
                  else
                    if ! pr_fields=$(gh pr list --state open --head "$pr_arg" --json number,url --jq 'if length == 0 then "" else .[0] | "\(.number)\t\(.url)" end'); then
                      echo "Failed to list PRs for branch $pr_arg" >&2
                      exit 1
                    fi
                  fi
                  if [[ -z "$pr_fields" ]]; then
                    echo "No open PR found for selector $pr_arg" >&2
                    exit 1
                  fi
                elif [[ "$run_branch" != "$default_branch" ]]; then
                  if ! pr_fields=$(gh pr list --state open --head "$run_branch" --json number,url --jq 'if length == 0 then "" else .[0] | "\(.number)\t\(.url)" end'); then
                    echo "Failed to list PRs for branch $run_branch" >&2
                    exit 1
                  fi
                fi

                local pr_number pr_url
                if [[ -n "$pr_fields" ]]; then
                  IFS=$'\t' read -r pr_number pr_url <<< "$pr_fields"
                else
                  local pr_list
                  if ! pr_list=$(gh pr list --state open --limit 50 --json number,url,title,headRefName,author --jq '.[] | "\(.number)\t\(.url)\t\(.title)\t\(.headRefName)\t\(.author.login)"'); then
                    echo "Failed to list open PRs" >&2
                    exit 1
                  fi
                  if [[ -z "$pr_list" ]]; then
                    echo "No open PRs found" >&2
                    exit 1
                  fi

                  local -a candidates candidate_urls candidate_titles candidate_heads
                  local pr_number_item pr_url_item pr_title_item pr_head_item pr_author_item
                  while IFS=$'\t' read -r pr_number_item pr_url_item pr_title_item pr_head_item pr_author_item; do
                    local files
                    if ! files=$(gh pr view "$pr_number_item" --json files --jq '.files[].path'); then
                      echo "Failed to read files for PR $pr_number_item" >&2
                      exit 1
                    fi
                    if echo "$files" | grep -Fxq "flake.lock"; then
                      candidates+=("$pr_number_item")
                      candidate_urls+=("$pr_url_item")
                      candidate_titles+=("$pr_title_item")
                      candidate_heads+=("$pr_head_item")
                    fi
                  done <<< "$pr_list"

                  local candidate_count=$#candidates
                  if [[ "$candidate_count" -eq 0 ]]; then
                    echo "No open PRs updating flake.lock found" >&2
                    exit 1
                  fi
                  if [[ "$candidate_count" -gt 1 ]]; then
                    echo "Multiple open PRs update flake.lock; pass a PR number to merge:" >&2
                    local i=1
                    while [[ "$i" -le "$candidate_count" ]]; do
                      echo "#$candidates[$i] $candidate_titles[$i] ($candidate_heads[$i]) $candidate_urls[$i]" >&2
                      i=$((i + 1))
                    done
                    exit 1
                  fi

                  pr_number=$candidates[1]
                  pr_url=$candidate_urls[1]
                fi

                if [[ -z "$pr_number" ]]; then
                  echo "No open PR matched the flake update criteria" >&2
                  exit 1
                fi

                local total_checks failing_checks
                if ! total_checks=$(gh pr view "$pr_number" --json statusCheckRollup --jq '.statusCheckRollup | length'); then
                  echo "Failed to read status checks for PR $pr_url" >&2
                  exit 1
                fi
                if [[ "$total_checks" -eq 0 ]]; then
                  echo "No status checks found for PR $pr_url" >&2
                  exit 1
                fi

                if ! failing_checks=$(gh pr view "$pr_number" --json statusCheckRollup --jq '[.statusCheckRollup[] | select(.status != "COMPLETED" or .conclusion != "SUCCESS")] | length'); then
                  echo "Failed to evaluate checks for PR $pr_url" >&2
                  exit 1
                fi
                if [[ "$failing_checks" -ne 0 ]]; then
                  echo "PR checks are not all green for $pr_url" >&2
                  exit 1
                fi

                gh pr review "$pr_number" --approve || exit 1

                local pr_state pr_automerge
                if ! pr_state=$(gh pr view "$pr_number" --json state --jq '.state'); then
                  echo "Failed to read PR state for $pr_url" >&2
                  exit 1
                fi
                if [[ "$pr_state" == "MERGED" ]]; then
                  git pull --ff-only || exit 1
                  exit 0
                fi

                if ! pr_automerge=$(gh pr view "$pr_number" --json autoMergeRequest --jq 'if .autoMergeRequest == null then "" else "enabled" end'); then
                  echo "Failed to read auto-merge state for $pr_url" >&2
                  exit 1
                fi
                if [[ -n "$pr_automerge" ]]; then
                  local attempt=0
                  while [[ "$attempt" -lt 10 ]]; do
                    if ! pr_state=$(gh pr view "$pr_number" --json state --jq '.state'); then
                      echo "Failed to read PR state for $pr_url" >&2
                      exit 1
                    fi
                    if [[ "$pr_state" == "MERGED" ]]; then
                      git pull --ff-only || exit 1
                      exit 0
                    fi
                    sleep 3
                    attempt=$((attempt + 1))
                  done
                fi

                gh pr merge "$pr_number" --merge || exit 1
                git pull --ff-only || exit 1
              )
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
