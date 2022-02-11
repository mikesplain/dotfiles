#!/bin/bash

. $HOME/.shrc

echo "Installing asdf plugins"

cut -d' ' -f1 ${HOME}/.tool-versions | xargs -I {} asdf plugin add {}


echo "Installing asdf tools"

asdf install