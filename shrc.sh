#!/bin/sh
# Colourful manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Set to avoid `env` output from changing console colour
export LESS_TERMEND=$'\E[0m'

# Print field by number
field() {
  ruby -ane "puts \$F[$1]"
}

# Setup paths
remove_from_path() {
  [ -d "$1" ] || return
  # Doesn't work for first item in the PATH but I don't care.
    export PATH=${PATH//:$1/}
}

add_to_path_start() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

add_to_path_end() {
  [ -d "$1" ] || return
  remove_from_path "$1"
  export PATH="$PATH:$1"
}

force_add_to_path_start() {
  remove_from_path "$1"
  export PATH="$1:$PATH"
}

quiet_which() {
  which "$1" &>/dev/null
}

# add_to_path_end "$HOME/Library/Python/2.7/bin"
add_to_path_end "$HOME/Library/Python/3.6/bin"
add_to_path_start "/usr/local/bin"
add_to_path_start "/usr/local/sbin"

# Brew python
# add_to_path_start "/usr/local/opt/python@2/libexec/bin"
# add_to_path_start "/usr/local/lib/python2.7/site-packages"

# Fix DYLD issue: https://stackoverflow.com/questions/58272830/python-crashing-on-macos-10-15-beta-19a582a-with-usr-lib-libcrypto-dylib
export DYLD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$DYLD_LIBRARY_PATH

# Run rbenv if it exists
# quiet_which rbenv && add_to_path_start "$(rbenv root)/shims"
rbenv() {
  eval "$(command rbenv init -)"
  rbenv "$@"
}

# Aliases
alias mkdir="mkdir -vp"
alias df="df -H"
alias rm="rm -iv"
alias mv="mv -iv"
alias zmv="noglob zmv -vW"
alias cp="cp -irv"
alias du="du -sh"
alias make="nice make"
alias less="less --ignore-case --raw-control-chars"
alias rsync="rsync -uav --partial --progress --human-readable --compress"
alias rake="noglob rake"
alias be="noglob bundle exec"
alias gist="gist --open --copy"
alias svn="svn-git.sh"
alias sha256="shasum -a 256"
alias ack="ag"
alias z="zeus"
alias zt="zeus test"
alias git="hub"
alias k='kubectl'
alias kk='kubectl "--context=${KUBECTL_CONTEXT:-$(kubectl config current-context)}" ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'
alias kns='kubens'
alias wk='watch -n.5 kubectl "--context=${KUBECTL_CONTEXT:-$(kubectl config current-context)}" ${KUBECTL_NAMESPACE/[[:alnum:]-]*/--namespace=${KUBECTL_NAMESPACE}}'
alias ktmux="tmux new-session -d 'watch -n.5 kubectl get nodes -L kops.k8s.io/instancegroup' && tmux split-window -h 'watch -n.5 kubectl get pods --all-namespaces --sort-by {.metadata.namespace}' && tmux split-window -v -t 1 && tmux -2 attach-session -d"
alias clear_dns_cache="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ktail="ktail --since-start"

# Platform-specific stuff
if quiet_which brew
then
  export BINTRAY_USER="$(git config bintray.username)"
  export HOMEBREW_PREFIX=$(brew --prefix)
  export BREW_REPO=$(brew --repo)
  export HOMEBREW_DEVELOPER=1
  export HOMEBREW_ANALYTICS=1
  export HOMEBREW_AUTO_UPDATE=1
  export HOMEBREW_FORCE_VENDOR_RUBY=1

  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if [ "$USER" = "brewadmin" ]
  then
    export HOMEBREW_CASK_OPTS="$HOMEBREW_CASK_OPTS --binarydir=$HOMEBREW_PREFIX/bin"
  fi

  alias hbc="cd $BREW_REPO/Library/Taps/homebrew/homebrew-core"
  alias hbv="cd $BREW_REPO/Library/Taps/homebrew/homebrew-versions"

  # Output whether the dependencies for a Homebrew package are bottled.
  brew_bottled_deps() {
    for DEP in "$@"; do
      echo "$DEP deps:"
      brew deps $DEP | xargs brew info | grep stable
      [ "$#" -ne 1 ] && echo
    done
  }

  # Output the most popular unbottled Homebrew packages
  brew_popular_unbottled() {
    brew deps --all |
      awk '{ gsub(":? ", "\n") } 1' |
      sort |
      uniq -c |
      sort |
      tail -n 500 |
      awk '{print $2}' |
      xargs brew info |
      grep stable |
      grep -v bottled
  }
fi

if [ $OSX ]
then
  export GREP_OPTIONS="--color=auto"
  export CLICOLOR=1
  if quiet_which diff-highlight
  then
    export GIT_PAGER='diff-highlight | less -+$LESS -RX'
  else
    export GIT_PAGER='less -+$LESS -RX'
  fi

  add_to_path_end /Applications/Xcode.app/Contents/Developer/usr/bin
  add_to_path_end /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
  add_to_path_end "$HOMEBREW_PREFIX/opt/git/share/git-core/contrib/diff-highlight"

  if quiet_which exa
  then
    alias ls="exa -Fg"
  else
    alias ls="ls -F"
  fi

  alias ql="qlmanage -p 1>/dev/null"
  alias locate="mdfind -name"
  alias cpwd="pwd | tr -d '\n' | pbcopy"
  alias finder-hide="setfile -a V"
elif [ $LINUX ]
then
  quiet_which keychain && eval `keychain -q --eval --agents ssh id_rsa`

  alias su="/bin/su -"
  alias ls="ls -F --color=auto"
  alias open="xdg-open"
elif [ $WINDOWS ]
then
  quiet_which plink && alias ssh="plink -l $(git config shell.username)"

  alias ls="ls -F --color=auto"

  open() {
    cmd /C"$@"
  }
fi

# Set up editor
if [ -n "${SSH_CONNECTION}" ] && quiet_which rmate
then
  export EDITOR="rmate"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR=$GIT_EDITOR
elif quiet_which mate
then
  export EDITOR="mate"
  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR="$GIT_EDITOR"
elif quiet_which subl || quiet_which sublime_text
then
  quiet_which subl && export EDITOR="subl"
  quiet_which sublime_text && export EDITOR="sublime_text" \
    && alias subl="sublime_text"

  export GIT_EDITOR="$EDITOR -w"
  export SVN_EDITOR="$GIT_EDITOR"
elif quiet_which nvim
then
  export EDITOR="nvim"
elif quiet_which vi
then
  export EDITOR="vi"
fi

# [ -f "$HOMEBREW_PREFIX/opt/kube-ps1/share/kube-ps1.sh" ] && source "$HOMEBREW_PREFIX/opt/kube-ps1/share/kube-ps1.sh"

# Run dircolors if it exists
quiet_which dircolors && eval $(dircolors -b)

# More colours with grc
[ -f "$HOMEBREW_PREFIX/etc/grc.bashrc" ] && source "$HOMEBREW_PREFIX/etc/grc.bashrc"

# Save directory changes
cd() {
  builtin cd "$@" || return
  [ $TERMINALAPP ] && which set_terminal_app_pwd &>/dev/null \
    && set_terminal_app_pwd
  pwd > "$HOME/.lastpwd"
  ls
}

# Disable thefuck
# eval $(thefuck --alias)
# eval $(thefuck --alias --enable-experimental-instant-mode)

# Use ruby-prof to generate a call stack
# ruby-call-stack() {
#   ruby-prof --printer=call_stack --file=call_stack.html -- "$@"
# }

# Use ruby-prof to generate a call stack
# rails-clean-migrate-branch() {
#   [ -n "$1" ] || return
#   git checkout master && git pull --rebase && rake db:setup db:migrate &&
#     git checkout -f "$1" && rake db:migrate
# }

# Pretty-print JSON files
json() {
  [ -n "$1" ] || return
  jsonlint "$1" | jq .
}

# Look in ./bin but do it last to avoid weird `which` results.
force_add_to_path_start "bin"

add_to_path_end "${KREW_ROOT:-$HOME/.krew}/bin"