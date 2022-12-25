#!/bin/bash

function helpText() {
  echo ""
  echo "Usage:"
  echo "  ddev-d10.sh {directory} {configuration}"
  echo ""
  echo "Configurations"
  echo "  basic - Starting modules"
  echo "  dev   - Basic + Full developer kit out"
  echo ""
}

function checkTargetDirectory() {
  if [ -e "$1" ]; then
    echo "Directory $1 already exists"
    exit
  fi
  TARGETDIR=$1
}

function checkConfiguration() {
  if [ "$1" = "" ]; then
    CONFIG="Basic"
  elif [ "$1" = "basic" ]; then
    CONFIG="Basic"
  elif [ "$1" = "dev" ]; then
    CONFIG="Dev"
  else
    echo "Unknown configuration: $1"
    exit
  fi
}

function directorySetup() {
  echo ""
  echo ">>> Creating directory: $1"
  mkdir -p "$1"
  cd "$1"
}

function ddevBaseSetup() {
  echo ""
  echo ">>> DDEV base setup"
  ddev config \
    --project-type=drupal10 \
    --docroot=web \
    --create-docroot \
    --mutagen-enabled

  ddev start
}

function composerBasicRequire() {
  echo ""
  echo ">>> Composer Basic configuration"
  yes | ddev composer create "drupal/recommended-project" --no-install
  ddev composer remove drupal/core-project-message
  ddev composer config --unset extra.drupal-core-project-message
  ddev composer config allow-plugins true --no-interaction
  ddev composer require drush/drush --no-install
  ddev composer require 'drupal/admin_toolbar:^3.1' --no-install
}

function composerDevRequire() {
  echo ""
  echo ">>> Composer Development configuration"
  ddev composer require --dev -W drupal/core-dev:^10 --no-install
  ddev composer require --dev phpspec/prophecy-phpunit:^2 --no-install
  ddev composer require --dev 'drupal/config_inspector:^2.0' --no-install
  ddev composer require --dev 'drupal/devel:^5.0' --no-install
  ddev composer config --json extra.drupal-scaffold.allowed-packages '["weitzman/drupal-test-traits"]'
  ddev composer require --dev "weitzman/drupal-test-traits:^2" --no-install
  ddev composer require --dev kint-php/kint --no-install
}

function localSettingsFile() {
  echo ""
  echo ">>> Adding settings.local.php file"
  cp web/sites/example.settings.local.php web/sites/default/settings.local.php
  # Append config to settings.php (easier than using SED to uncomment)
  cat << 'EOF' >> web/sites/default/settings.php

$settings['config_sync_directory'] = '../config/sync';

if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}
EOF
}

function buildAndInstall() {
  echo ""
  echo ">>> Composer and Drush install"
  ddev composer install
  ddev drush site:install --site-name="$TARGETDIR Test Site" -y
  ddev drush cr
}

function drushBasicEnableModules() {
  echo ""
  echo ">>> Enable basic modules"
  ddev drush en admin_toolbar,admin_toolbar_tools
}

function main() {
  if [ "$#" = 0 ]; then
    helpText
    exit
  fi;

  checkTargetDirectory "$1"
  checkConfiguration "$2"

  directorySetup $TARGETDIR

  ddevBaseSetup
  composerBasicRequire
  if [ "$CONFIG" = "Dev" ]; then composerDevRequire; fi
  buildAndInstall
  localSettingsFile
  drushBasicEnableModules

  echo ""
  echo "Install complete!!"
  echo "cd to $TARGETDIR to begin"
  echo ""
  ddev launch
  ddev drush uli
}

main "$@"
