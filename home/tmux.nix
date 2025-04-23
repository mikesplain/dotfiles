{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-b";
    escapeTime = 10;
    historyLimit = 50000;
    keyMode = "vi";
    mouse = false;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'coral'
        '';
      }
    ];

    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Window and pane configuration
      set -g base-index 1           # start windows numbering at 1
      setw -g pane-base-index 1     # make pane numbering consistent with windows
      setw -g automatic-rename on   # rename window to reflect current program
      set -g renumber-windows on    # renumber windows when a window is closed
      set -g set-titles on          # set terminal title
      set -g display-panes-time 800 # slightly longer pane indicators display time
      set -g display-time 1000      # slightly longer status messages display time
      set -g status-interval 10     # redraw status line every 10 seconds

      # Clear both screen and history
      bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history

      # Activity monitoring
      set -g monitor-activity on
      set -g visual-activity off

      # -- Navigation ----------------------------------------------------------------
      # Create session
      bind C-c new-session

      # Find session
      bind C-f command-prompt -p find-session 'switch-client -t %%'

      # Session navigation
      bind BTab switch-client -l  # move to last session

      # Window splitting
      bind - split-window -v
      bind _ split-window -h

      # Pane navigation
      bind -r h select-pane -L  # move left
      bind -r j select-pane -D  # move down
      bind -r k select-pane -U  # move up
      bind -r l select-pane -R  # move right
      bind > swap-pane -D       # swap current pane with the next one
      bind < swap-pane -U       # swap current pane with the previous one

      # Pane resizing
      bind -r H resize-pane -L 2
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 2

      # Window navigation
      unbind n
      unbind p
      bind -r C-h previous-window # select previous window
      bind -r C-l next-window     # select next window
      bind Tab last-window        # move to last active window

      # Prefix configuration
      set -gu prefix2
      unbind C-a
      unbind C-b
      set -g prefix C-b
      bind C-b send-prefix

      # Fix issue with tmux loading sh instead of zsh
      set -gu default-command
      set -g default-shell "$SHELL"
    '';
  };
}