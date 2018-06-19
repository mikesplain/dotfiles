#!/bin/bash

sudo spctl --master-disable
brew update

# Remove casks and mas since they're big
sed -i '' 's/.*cask.*//g' Brewfile
sed -i '' 's/.*mas.*//g' Brewfile

brew bundle install