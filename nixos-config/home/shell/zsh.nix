{ pkgs, ... }: {

  programs.zsh = {
    enable = true;
    # enableBashCompletion = true;
    # enableCompletion = true;
    # enableSyntaxHighlighting = true;
    # loginShellInit = "neofetch --config /etc/neofetch/config.conf";
    # interactiveShellInit = builtins.readFile zshrc;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      ls = "eza -g";
      l = "eza -la";
      la = "l";
      ll = "l";
      # ls = "ls --color=auto -F";
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
    };
    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

    initExtra = ''
    eval $(/run/current-system/sw/bin/brew shellenv)
    autoload -U select-word-style
    select-word-style bash

    . "${pkgs.asdf-vm}/share/asdf-vm/asdf.sh"
    . "${pkgs.asdf-vm}/share/asdf-vm/completions/asdf.bash"
    '';

  };
}