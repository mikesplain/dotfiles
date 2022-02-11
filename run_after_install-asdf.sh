#!/bin/sh

. $HOME/.shrc

cut -d' ' -f1 $HOME/.tool-versions | xargs -I {} asdf plugin add {}
asdf install