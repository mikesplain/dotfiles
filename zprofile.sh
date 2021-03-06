# load shared shell configuration
source ~/.shprofile

# Enable completions
# autoload -U compinit && compinit
# From https://gist.github.com/ctechols/ca1035271ad134841284
setopt extendedglob
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

if which brew &>/dev/null
then
  [ -w $HOMEBREW_PREFIX/bin/brew ] && \
    [ ! -f $HOMEBREW_PREFIX/share/zsh/site-functions/_brew ] && \
    mkdir -p $HOMEBREW_PREFIX/share/zsh/site-functions &>/dev/null && \
    ln -s $HOMEBREW_PREFIX/Library/Contributions/brew_zsh_completion.zsh \
          $HOMEBREW_PREFIX/share/zsh/site-functions/_brew
  export FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"
fi

# Remove Ruby on command line
RPROMPT=''

# Enable regex moving
autoload -U zmv

# Style ZSH output
zstyle ':completion:*:descriptions' format '%U%B%F{red}%d%f%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Case insensitive globbing
setopt no_case_glob

# Expand parameters, commands and aritmatic in prompts
setopt prompt_subst

# Colorful prompt with Git and Subversion branch
autoload -U colors && colors

git_branch() {
  GIT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  [ -n "$GIT_BRANCH" ] && echo "($GIT_BRANCH) "
}

svn_branch() {
  [ -d .svn ] || return
  SVN_INFO=$(svn info 2>/dev/null) || return
  SVN_BRANCH=$(echo $SVN_INFO | grep URL: | grep -oe '\(trunk\|branches/[^/]\+\|tags/[^/]\+\)')
  [ -n "$SVN_BRANCH" ] || return
  # Display tags intentionally so we don't write to them by mistake
  echo "(${SVN_BRANCH#branches/}) "
}

# more OS X/Bash-like word jumps
export WORDCHARS=''

# use emacs bindings even with vim as EDITOR
bindkey -e

# fix backspace on Debian
[ $LINUX ] && bindkey "^?" backward-delete-char

# fix delete key on OSX
[ $OSX ] && bindkey "\e[3~" delete-char

## for tmux bar
PS1="$PS1"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'

# Fix sierra issue: https://github.com/tmux/tmux/issues/475
export EVENT_NOKQUEUE=1


# Shortcut and autocomplete for ~/code
c() { cd ~/code/$1;  }

_c() { _files -W ~/code -/; }
compdef _c c

# Shortcut and autocomplete for ~/go
godir() { cd ~/go/$1;  }

_godir() { _files -W ~/go -/; }
compdef _godir godir

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Source barkly file if it exists
if [ -f "$HOME/.env/splain.sh" ]; then
  source "$HOME/.env/splain.sh"
fi

if [ -f "$HOME/.env/kops.sh" ]; then
  source "$HOME/.env/kops.sh"
fi

if type nvim > /dev/null 2>&1; then
  alias vi='nvim'
  alias vim='nvim'
fi

alias git-clean-branches='git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d'

alias gut='git'
