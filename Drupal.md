
# Drupal Project

## How to install the drupal in linux system?
## How to install the PHP in linux system?

```shell
# here are the steps to install PHP 8.2, Nginx, PHP-FPM, Composer, Drush, and Drupal on Ubuntu 18.04 LTS:

# Install PHP 8.2:

sudo apt-get update
sudo apt-get install php8.2

# Install Nginx:

sudo apt-get install nginx

# Install PHP-FPM:

sudo apt-get install php8.2-fpm

# Install Composer:

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

# Install Drush:

sudo apt-get install php8.2-cli
sudo composer global require drush/drush

# Install Drupal:

cd /var/www/
sudo chown -R www-data:www-data /var/www/
sudo chmod -R 755 /var/www/
composer create-project drupal/recommended-project mysite

# Replace "mysite" with the desired name of your Drupal installation.

# Configure Nginx:

sudo nano /etc/nginx/sites-available/mysite

# Replace "mysite" with the name of your Drupal installation. Paste the following into the file:
   
server {
listen 80;
listen [::]:80;
server_name example.com;
root /var/www/mysite/web;
index index.php;
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
   
# Save and exit the file. Then, create a symbolic link to enable the site and restart Nginx:

sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Configure Drupal:

cd /var/www/mysite/
cp .env.example .env

# Edit the .env file to set your database credentials and site URL.

# Install Drupal:

cd /var/www/mysite/
sudo chown -R www-data:www-data sites/default/files
sudo chmod -R 755 sites/default/files
drush site:install

# Follow the prompts to complete the Drupal installation.
# That's it! You should now have a working Drupal installation on Ubuntu 18.04 LTS with PHP 8.2, Nginx, PHP-FPM, Composer, and Drush.
```

## What are the recommended file and folder permissions?
Here's an example shell script to set Drupal 9 folder and file permissions:

```shell
#!/bin/bash

# Change directory to the root of your Drupal 9 installation
cd /var/www/html/drupal9

# Set folder permissions
find . -type d -exec chmod 755 {} \;

# Set file permissions
find . -type f -exec chmod 644 {} \;

# Set permissions for the "sites/default/files" directory
chmod -R 777 sites/default/files

# Set the permissions for the settings.php file
chmod 640 sites/default/settings.php

# Set the permissions for the .htaccess file
chmod 440 .htacces"
```

## Top drush commands

```shell
drush status
Provides a brief overview of your Drupal installation.
Example: drush status


drush dl (download)
Downloads a Drupal project.
Example: drush dl views


drush en (enable)
Enables a module or theme.
Example: drush en admin_toolbar


drush pm-uninstall (or dis for older versions)
Uninstalls a module.
Example: drush pm-uninstall admin_toolbar
To uninstall all unused modules.
Example: drush pm-uninstall $(drush pm-list --status=disabled --type=module --no-core --field=name)


drush up (update)
Updates Drupal core and contributed projects.
Example: drush up


drush cc (cache-clear)
Clears all caches.
Example: drush cc all


drush cr (cache-rebuild)
Rebuilds the cache.
Example: drush cr


drush cget (config-get)
Gets a configuration value.
Example: drush cget system.site name


drush cset (config-set)
Sets a configuration value.
Example: drush cset system.site name "My new site name"


drush cex (config-export)
Exports the active configuration to a file.
Example: drush cex


drush cim (config-import)
Imports configuration from a file to the active store.
Example: drush cim


drush sql-dump
Exports the Drupal database as SQL.
Example: drush sql-dump --result-file=db_backup.sql
Export database as gzip.
Example: drush sql-dump --result-file=/path/to/export.sql --gzip --all-tables


drush sql-cli (sql-connect)
Opens a SQL command-line interface.
Example: drush sql-cli
Import database from .sql file
Example: drush sql-cli < /path/to/import.sql



drush sql-query (sqlq)
Executes a SQL query.
Example: drush sql-query "SELECT * FROM users;"


drush sql-drop
Drops all database tables.
Example: drush sql-drop


drush uli (user-login)
Generates a one-time login URL for a user.
Example: drush uli


drush user-create
Creates a new user account.
Example: drush user-create johndoe --mail="john@example.com" --password="mypassword"


drush user-block
Blocks a user account.
Example: drush user-block johndoe


drush user-unblock
Unblocks a user account.
Example: drush user-unblock johndoe


drush watchdog-show (ws)
Shows the most recent log messages.
Example: drush ws
Show last 10 errors.
Example: drush watchdog-show --count=10
Example: drush watchdog-show --count=10 --severity=3
Delete all watchdog table entries.
Example: drush watchdog-delete-all
Export logs
Example: drush watchdog-export > watchdog_logs.txt



drush pm-list (pml)
Displays a list of available extensions (modules and themes).
Example: drush pm-list
Print all custom module name.
Example: drush pm-list --type=module --no-core --status=enabled --fields=name,package --format=table | grep "Custom" | awk '{print $1}'


drush pm-info (pmi)
Displays information about a specific extension.
Example: drush pm-info views


drush pm-projectinfo (pmi)
Displays information about a specific project.
Example: drush pm-projectinfo views


drush pm-releasenotes (pm-releasenotes)
Displays the release notes for a specific project.
Example: drush pm-releasenotes views


drush pm-updatecode (pm-updatecode)
Updates code for a specific project.
Example: drush pm-updatecode views


drush pm-updatestatus (pm-updatestatus)
Displays update status for projects.
Example: drush pm-updatestatus


drush core-requirements (core-requirements)
Displays a list of Drupal core requirements.
Example: drush core-requirements


drush core-status (core-status)
Provides a brief overview of your Drupal installation.
Example: drush core-status


drush core-cron (core-cron)
Runs all cron hooks in all active modules.
Example: drush core-cron


drush core-execute (core-execute)
Executes a shell command.
Example: drush core-execute "ls -la"


drush core-quick-drupal (core-quick-drupal)
Downloads, installs, and serves a Drupal site.
Example: drush core-quick-drupal


drush field-info-fields (field-info-fields)
Displays a list of fields.
Example: drush field-info-fields


drush field-info-instances (field-info-instances)
Displays a list of field instances.
Example: drush field-info-instances


drush language-add (language-add)
Adds a new language.
Example: drush language-add fr


drush language-enable (language-enable)
Enables a language.
Example: drush language-enable fr


drush language-disable (language-disable)
Disables a language.
Example: drush language-disable fr


drush language-default (language-default)
Sets the default language.
Example: drush language-default fr


drush locale-update (locale-update)
Updates translations.
Example: drush locale-update


drush search-index (search-index)
Indexes remaining search items.
Example: drush search-index


drush search-reindex (search-reindex)
Rebuilds the search index.
Example: drush search-reindex
```

## How to install composer?

```shell

# check if global composer exists
which composer

# example to find the global composer and execute the command
sudo $(which composer) require 'drupal/minifyhtml:^1.11'

# if no composer exists, download the phar file
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# check the hash
sudo HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"

# match the hash
sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

# install composer
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# check composer version
composer -V

# update composer if required
composer self-update
```

## Clear Drupal Cache using MYSQL query:

```sql
DELETE FROM `cache_bootstrap`;
DELETE FROM `cache_config`;
DELETE FROM `cache_container`;
DELETE FROM `cache_data`;
DELETE FROM `cache_default`;
DELETE FROM `cache_discovery`;
DELETE FROM `cache_dynamic_page_cache`;
DELETE FROM `cache_entity`;
DELETE FROM `cache_menu`;
DELETE FROM `cache_render`;
DELETE FROM `cache_toolbar`;
```