# DDEV Scripts

## Shell

Scripts to link in ~/bin for DDEV related activities like deleting an old instance or created a configured one.

| Name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| Function |
|:--------------------|-------|
| ddev-ab-localize.sh | Creates a `config.local.yaml` file with preferred customizations. Used when it's not appropriate to modify the project `config.yaml`. For example, when the project is shared and my configurations are the outlier. |
| ddev-d10.sh | Creates a Drupal 10 installation. Has options for a basic or development configuration. |
| ddev-drupalcreate.sh | Creates a standard Drupal 9 installation. |
| ddev-drupalcreatedev.sh | Creates a standard Drupal 9 installation with the addition of developer modules and configuration files. |
| ddev-wipe.sh | Cleanly deletes a DDEV installation. i.e.: Insures the directory and images are removed. |

### ddev-d10.sh

Creates a 10 site in DDEV. 

Has options to create a regular site or add developer modules for a development site.

**Usage:**

`ddev-d10 {project-directory} [dev]`

**Notes:**

- The installation is created in the current working directory
- The `dev` flag installs the common composer and Drupal development tools 
- Only tested on a Mac
- DDEV Mutagen is enabled (because Mac)


### ddev-drupalcreate.sh

Creates a Drupal 9 site in DDEV.

**Usage:**

`ddev-drupalcreate [directory]`

**Notes:**

- `directory` is created in the current working directory
- Only tested on a Mac
- The DDEV http/https ports are changed to 8080 and 8043 to avoid conflicts with other http daemons
- DDEV Mutagen is enabled (because Mac)
- A number of common Drupal modules are added (e.g.: devel, admin_toobar)
