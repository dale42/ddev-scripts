#!/bin/bash

if [ ! -d ".ddev" ]; then
  echo "This does not appear to be a DDEV project (no .ddev directory)"
  exit
fi;

if [ -f ".ddev/config.local.yaml" ]; then
  echo "This DDEV project already has a config.local.yaml file"
  exit
fi;

git config --local user.email dale@affinitybridge.com
git config core.filemode false

ProjectDir="$(basename "$(pwd)")"

cd .ddev

cat << EOF >> config.local.yaml
name: $ProjectDir
router_http_port: "8080"
router_https_port: "8043"
mutagen_enabled: true

EOF
