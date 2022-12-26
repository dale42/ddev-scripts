#!/bin/bash

## Custom command for PHP Code Sniffer with ddev configuration
## Description: Runs PHP Code Sniffer, phpcs, with configuration from testing/ddev
## Usage: runcs
## Example: "ddev runcs"

cd testing/ddev
../../vendor/bin/phpcs "$@"
exit 0
