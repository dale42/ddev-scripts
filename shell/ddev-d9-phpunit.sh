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

cp /Users/dale/Virtuals/test/.ddev/docker-compose.chromedriver.yml .ddev/.

ddev start


#ddev restart

yes | ddev composer create "drupal/recommended-project" --no-install
ddev composer config allow-plugins true --no-interaction
ddev composer require drush/drush --no-install
ddev composer require --dev -W drupal/core-dev --no-install
ddev composer require --dev phpspec/prophecy-phpunit:^2 --no-install
ddev composer require 'drupal/admin_toolbar:^3.1' --no-install
ddev composer require 'drupal/devel:^4.1' --no-install
ddev composer install
ddev drush site:install -y
ddev drush cr
ddev drush en admin_toolbar,admin_toolbar_tools,devel

if [ "$2" != "" ]; then
  cd web/modules/contrib
  git clone https://git.drupalcode.org/project/$2.git
fi;

cp /Users/dale/Virtuals/test/phpunit.xml .

ddev drush uli
ddev launch
