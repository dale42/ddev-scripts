#!/bin/bash

## Custom command for PHPStan with ddev configuration
## Description: Runs PHPStan static analysis, phpstan, with configuration from testing/ddev
## Usage: runphpstan
## Example: "ddev runphpstan"

cd testing/ddev
../../vendor/bin/phpstan "$@"
exit 0
