
# Drupal Project
---

**Drupal Database Management Guide**

This guide outlines essential commands for managing a Drupal database efficiently, including exporting, dropping, and importing database files. 

### Export Drupal Database in Gzip File (Excluding Cache Data)
To export your Drupal database into a gzip file, excluding cache data, use the following command:
```shell
drush sql-dump --gzip --result-file=/path/to/db-file.sql
```

### Drop Drupal Database
To drop (delete) your Drupal database, you can use the following command:
drush sql-drop -y

### Import SQL File to Drupal Database
To import an SQL file into your Drupal database, execute the following command:
```shell
drush sql-cli < ~/path/to/db-file.sql
```

### Import Gzip File in Drupal Database (Option 1)
To import a gzip file into your Drupal database, you can use the following command:
```shell
zcat < /path/to/your/file.sql.gz | drush sql-cli
gunzip < /path/to/your/file.sql.gz | drush sql-cli
drush sqlq --file=/path/to/your/file.sql.gz
```

### Import Gzip File in Drupal Database (Option 2)
Alternatively, you can import a gzip file using the `sql-p` command with gzip compression:
```shell
drush sql-p --gzip /path/to/your/file.sql.gz
```

### Export Specific Tables
You can export specific tables from your Drupal database by using the `--tables-list` option with the `sql-dump` command. For example, to export only the `node` and `system` tables, execute:
```shell
drush sql-dump --tables-list=node,system > exportdb.sql
```

# Delete Older Revisions for All Content Types

This PHP script deletes older revisions for all content types in a Drupal site. It's particularly useful for managing database bloat and optimizing site performance by removing unnecessary revisions.

## Usage

1. **Set Memory and Execution Limits**

   Ensure that your PHP configuration allows for sufficient memory and execution time. This script increases memory limit to 4000M and sets execution time to unlimited.

2. **Include Required Dependencies**

   This script uses the EntityTypeManagerInterface interface from the Drupal Core Entity module. Ensure that your Drupal installation includes this module.

3. **Function Definition: delete_older_revisions_for_all_types**

   This function queries all content types, loads their nodes, and deletes older revisions, keeping only the latest 2 revisions.

   **Parameters:**
   - `$entityTypeManager`: An instance of the EntityTypeManagerInterface interface.

4. **Execute the Script**

   Call the `delete_older_revisions_for_all_types()` function passing an instance of the EntityTypeManagerInterface interface as an argument.

## Important Note

- **Backup Your Database**: Before executing this script, ensure that you have a recent backup of your Drupal database. Deleting revisions is irreversible, and having a backup ensures that you can restore your data if needed.

## Script
```php
<?php
ini_set('memory_limit', '4000M');
set_time_limit(0);
ini_set('max_execution_time', 0);

use Drupal\Core\Entity\EntityTypeManagerInterface;
// Define a function to delete older revisions for all content types.
function delete_older_revisions_for_all_types(EntityTypeManagerInterface $entityTypeManager)
{
    $query = $entityTypeManager->getStorage('node')
        ->getQuery()
        ->sort('type', 'DESC');
    $contentTypes = $query->execute();
    // Loop through each content type.
    foreach ($contentTypes as $contentType) {
        $node = $entityTypeManager->getStorage('node')->load($contentType);
        // Load all revisions of the current entity.
        $revisionIds = $entityTypeManager->getStorage('node')->revisionIds($node);
        // Sort revisions by revision ID in descending order.
        krsort($revisionIds);
        // Keep only the last 2 revisions.
        $revisionsToKeep = array_slice($revisionIds, 0, 2);
        // Delete older revisions.
        foreach ($revisionIds as $revisionId) {
            if (!in_array($revisionId, $revisionsToKeep)) {
                $entityTypeManager->getStorage('node')->deleteRevision($revisionId);
                echo PHP_EOL . "RevID: $revisionId deleted" . PHP_EOL;
            }
        }
    }
}
// Call the function to delete older revisions for all content types.
delete_older_revisions_for_all_types(\Drupal::entityTypeManager());
```

## How to use/run/execute

Let's save the script as `node_revision_delete.php` in drupal root folder. Now you can use **drush** to run this file e.g. `./drush php:script node_revision_delete.php`

---

# Delete Multiple Path Aliases for Published Nodes

This PHP script is designed to delete multiple path aliases for each published node in a Drupal site, leaving only the canonical alias intact. It helps in managing and cleaning up unnecessary aliases associated with nodes.

## Usage

1. **Ensure Proper Configuration**

   Ensure that your Drupal site is properly configured and running. This script is intended to be executed within a Drupal environment.

2. **Include the Script**

   Copy the provided PHP script into a file within your Drupal project directory.

3. **Execute the Script**

   Run the script through your preferred method of executing PHP scripts. For example, you can execute it via the command line or create a custom PHP script runner within Drupal.

   ```bash
   php delete_multiple_aliases.php
   ```

4. **Review Output**

   The script will iterate through each published node, load its aliases, and delete all aliases except the canonical one. Any relevant output or errors will be displayed during execution.

## Important Notes

- **Backup Your Database**: Before executing this script, ensure that you have a recent backup of your Drupal database. Deleting aliases is irreversible, and having a backup ensures that you can restore your data if needed.

- **Customization**: You may customize the script further according to your specific requirements. For example, you can modify it to handle different conditions or to delete aliases for specific content types.

## Script
```php
<?php

use Drupal\Core\Entity\EntityTypeManagerInterface;

$query = \Drupal::entityQuery('node')
  // excluding offers  
  ->condition('type', 'offers', '!=')
  // excluding art_meetings
  ->condition('type', 'art_meetings', '!=')
  // excluding leela_palace_trail
  ->condition('type', 'leela_palace_trail', '!=')
  // excluding explore_destination
  ->condition('type', 'explore_destination', '!=')
  // Filter by published nodes
  ->condition('status', 1);

$nids = $query->execute();

foreach ($nids as $nid) {
  // Load the node
  $node = \Drupal::entityTypeManager()->getStorage('node')->load($nid);
  if ($node) {
    // Get the canonical path of the node
    $canonical_path = '/node/' . $nid;
    
    // Load all aliases for the node
    $alias_storage = \Drupal::entityTypeManager()->getStorage('path_alias');
    $alias_objects = $alias_storage->loadByProperties(['path' => $canonical_path]);

    // Delete all aliases except the canonical one
    $count = 0;
    foreach ($alias_objects as $alias_object) {
      if ($count > 0) {
        $alias_object->delete();
      }
      $count++;
    }
  }
}
```

## How to use/run/execute

Let's save the script as `delete_alias.php` in drupal root folder. Now you can use **drush** to run this file e.g. `./drush php:script delete_alias.php`

---


## How to install PHP 8.2, Nginx, PHP-FPM, Composer, Drush, and Drupal in linux system?

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
