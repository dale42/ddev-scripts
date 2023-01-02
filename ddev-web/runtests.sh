#!/bin/bash

## Custom command for phpunit with ddev configuration
## Description: Runs phpunit with configuration from testing/ddev
## Usage: runtests
## Example: "ddev runtests"

./vendor/bin/phpunit -c ./testing/ddev --testdox "$@"
