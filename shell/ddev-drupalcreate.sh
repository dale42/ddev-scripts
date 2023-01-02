#!/bin/bash

if [ "$1" = "" ]; then
  read -p "Project directory: " Response
  if [ "$Response" = "" ]; then
    exit
  fi
  HOMEDIR=$Response
else
  HOMEDIR=$1
fi

if [ -e ~$HOMEDIR ]; then
  echo "Directory $HOMEDIR already exists"
  exit
fi

mkdir -p $HOMEDIR
cd $HOMEDIR

ddev config --project-type=drupal9 \
  --docroot=web \
  --create-docroot \
  --php-version=7.4 \
  --mutagen-enabled

ddev start
yes | ddev composer create "drupal/recommended-project:^9.5.0" --no-install
ddev composer config allow-plugins true --no-interaction
ddev composer require drush/drush --no-install
ddev composer require 'drupal/admin_toolbar:^3.1' --no-install
ddev composer install
ddev drush site:install --site-name="$HOMEDIR Test Site" -y
ddev drush cr
ddev drush en admin_toolbar,admin_toolbar_tools
ddev drush uli
ddev launch
