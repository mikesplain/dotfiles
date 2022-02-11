#!/bin/bash

. $HOME/.shrc

echo "Installing asdf plugins"

cut -d' ' -f1 ${HOME}/.tool-versions

cut -d' ' -f1 ${HOME}/.tool-versions | xargs -I R asdf plugin add R


echo "Installing asdf tools"

asdf install