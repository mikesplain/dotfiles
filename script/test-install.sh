#!/bin/bash

sudo spctl --master-disable
brew update

# Remove casks and mas since they're big
sed -i '' 's/^cask.*//g' Brewfile
sed -i '' 's/^mas.*//g' Brewfile

# Remove iftop since it gives a sudo error
sed -i '' 's/.*iftop.*//g' Brewfile

# For linux
# brew cask install homebrew/cask-versions/java8
brew install python
brew link --overwrite python

brew bundle install --no-upgrade
