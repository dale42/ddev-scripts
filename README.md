# DDEV Scripts

## Shell

Scripts to link in ~/bin for DDEV related activities like deleting an old instance or created a configured one.

| Name                | Function |
|---------------------|-------|
| ddev-ab-localize.sh | Creates a `config.local.yaml` file with preferred customizations. Used when it's not appropriate to modify the project `config.yaml`. For example, when the project is shared and my configurations are the outlier. |
| ddev-drupalcreate.sh | Creates a standard Drupal installation. |
| ddev-drupalcreatedev.sh | Creates a standard Drupal installation with the addition of developer modules and configuration files. |
| ddev-wipe.sh | Cleanly deletes a DDEV installation. i.e.: Insures the directory and images are removed. |
