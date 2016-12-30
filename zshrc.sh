# load shared shell configuration
source ~/.zprofile
source ~/.shrc

# History file
export HISTFILE=~/.zsh_history

# Don't show duplicate history entires
setopt hist_find_no_dups

# Remove unnecessary blanks from history
setopt hist_reduce_blanks

# Share history between instances
setopt share_history

# Don't hang up background jobs
setopt no_hup

ZSH_THEME="wedisagree"
## for tmux bar
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'

eval "$(thefuck --alias)"

# Fix sierra issue: https://github.com/tmux/tmux/issues/475
export EVENT_NOKQUEUE=1

plugins=(git brew ruby bundler docker)

c() { cd ~/cylent/$1;  }

_c() { _files -W ~/cylent -/; }
compdef _c c
