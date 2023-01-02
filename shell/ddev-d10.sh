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

function variablesSetup() {
  ROOTDIRECTORY=$(dirname $(dirname $(readlink -fn $0)))
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
  cat "$ROOTDIRECTORY/files/post-start-hook-fragment.yaml" >> .ddev/config.yaml

  ddev start

  cp "$ROOTDIRECTORY/ddev-host/login.sh" .ddev/commands/host/.
}

function ddevDevSetup() {
  ddev get drud/ddev-selenium-standalone-chrome
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

function setupDevEnvironment() {
  echo ""
  echo ">>> Test Environment setup"

  # Testing directory
  mkdir -p testing/ddev

  # PHPUnit w/weitzman DDT
  echo " - PHPUnit w/weitzman DDT"
  cp vendor/weitzman/drupal-test-traits/docs/phpunit-dtt.xml testing/ddev/.
  cp "$ROOTDIRECTORY/ddev-web/runtests.sh" .ddev/commands/web/.

  # PHP Code Sniffer
  echo " - PHP Code Sniffer (phpcs)"
  cp "$ROOTDIRECTORY/files/phpcs.xml" testing/ddev/.
  cp "$ROOTDIRECTORY/ddev-web/runcs.sh" .ddev/commands/web/.

  # PHPStan
  echo " - PHPStan"
  cp "$ROOTDIRECTORY/files/phpstan.neon" testing/ddev/.
  cp "$ROOTDIRECTORY/ddev-web/runphpstan.sh" .ddev/commands/web/.
}

function buildAndInstall() {
  echo ""
  echo ">>> Composer and Drush install"
  ddev composer install
  ddev drush site:install --site-name="$TARGETDIR Test Site" -y
  ddev drush cr
  mkdir web/modules/custom
}

function enableBasicModules() {
  echo ""
  echo ">>> Enable basic modules"
  ddev drush en admin_toolbar,admin_toolbar_tools
}

function main() {
  if [ "$#" = 0 ]; then
    helpText
    exit
  fi;

  variablesSetup

  checkTargetDirectory "$1"
  checkConfiguration "$2"

  directorySetup $TARGETDIR

  ddevBaseSetup
  if [ "$CONFIG" = "Dev" ]; then ddevDevSetup; fi
  composerBasicRequire
  if [ "$CONFIG" = "Dev" ]; then composerDevRequire; fi
  buildAndInstall
  localSettingsFile
  if [ "$CONFIG" = "Dev" ]; then setupDevEnvironment; fi
  enableBasicModules

  echo ""
  echo "|"
  echo "|  Install complete!!"
  echo "|  cd to $TARGETDIR to begin"
  echo "|"
  ddev login
}

main "$@"
