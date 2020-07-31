#!/bin/bash

[ $(uname -s) = "Darwin" ] && export OSX=1 && export UNIX=1
[ $(uname -s) = "Linux" ] && export LINUX=1 && export UNIX=1
uname -s | grep -q "_NT-" && export WINDOWS=1

sudo spctl --master-disable
brew update

# Remove install bazelisk
rm '/usr/local/bin/bazelisk'
# Removed installed bazel
rm '/usr/local/bin/bazel'

# Remove casks and mas since they're big
sed -i '' 's/^cask.*//g' Brewfile
sed -i '' 's/^mas.*//g' Brewfile

# Remove iftop since it gives a sudo error
sed -i '' 's/.*iftop.*//g' Brewfile

if [ $OSX ]; then
  # For linux
  # brew cask install homebrew/cask-versions/java8
  brew unlink python
  brew unlink python@2
  brew upgrade python
  brew link --overwrite python

  brew install node
  brew link --overwrite node

  brew bundle install --no-upgrade
fi

# ASDF Install
source $HOME/.shrc
asdf install