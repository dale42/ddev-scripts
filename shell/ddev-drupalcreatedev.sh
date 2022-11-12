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
  --http-port=8080 \
  --https-port=8043 \
  --php-version=7.4 \
  --mutagen-enabled

ddev start
yes | ddev composer create "drupal/recommended-project" --no-install
ddev composer config allow-plugins true --no-interaction
ddev composer require --dev -W drupal/core-dev:^9.4 --no-install
ddev composer require --dev phpspec/prophecy-phpunit:^2 --no-install
ddev composer require --dev 'drupal/config_inspector:^2.0' --no-install
ddev composer require drush/drush:^11.0 --no-install
ddev composer require 'drupal/admin_toolbar:^3.1' --no-install
ddev composer require 'drupal/devel:^5.0' --no-install
ddev composer install
ddev drush site:install --site-name="$HOMEDIR Test Site" -y
ddev drush cr

#
# Create settings.local.php
#
cp web/sites/example.settings.local.php web/sites/default/settings.local.php

#
# Append config to settings.php (easier than SED to uncomment)
#
cat << 'EOF' >> web/sites/default/settings.php

$settings['config_sync_directory'] = '../config/sync';

if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}
EOF

#
# Configure Drupal modules
#
ddev drush en admin_toolbar,admin_toolbar_tools,devel

if [ "$2" != "" ]; then
  cd web/modules/contrib
  git clone https://git.drupalcode.org/project/$2.git
fi;

ddev drush uli
ddev launch
