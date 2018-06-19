#!/bin/bash

sudo spctl --master-disable
brew update
brew bundle list --taps | xargs -n1 brew tap
brew bundle list --brews | xargs -n1 brew install
