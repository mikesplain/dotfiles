#!/bin/bash

remote=`git remote -v | awk '/\(push\)$/ {print $2}'`
email=mike.splain@gmail.com # default

if [[ $remote == *github.com:Microsoft* ]]; then
  email=mike.splain@sonos.com
fi

echo "Configuring user.email as $email"
echo git config user.email $email