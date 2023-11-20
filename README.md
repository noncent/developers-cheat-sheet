># Essential Drupal Commands
---

## Drupal Files and Folders Permissions

To ensure the proper functioning of Drupal CMS, it's crucial to manage file and folder permissions appropriately. Below are commands that address permissions for various Drupal components:

```bash
# Set permissions for default Drupal directories
chmod 755 /default
chmod -R 744 /default/files
chmod -R 755 /default/themes
chmod -R 755 /default/modules
chmod 444 /default/settings.php
chmod 444 /default/default.settings.php

# Navigate to the base project folder
cd /opt/www-site-com

# Change Drupal folder permissions
chown -R nginx: drupal && chmod -R 777 drupal

# Move inside the Drupal directory
cd drupal

# Install Composer
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
sudo php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer -V

# Composer self-update
composer self-update

# Run Composer commands
sudo $(which composer) require 'drupal/minifyhtml:^1.11'
composer require 'drupal/key:^1.16' 'drupal/menu_item_extras:^2.19' 'drupal/paragraphs:^1.15' 'drupal/queue_ui:^3.1' 'drupal/real_aes:^2.5' 'drupal/s3fs:^3.1' 'drupal/services:^4.0@beta' 'drupal/smtp:^1.2' --with-all-dependencies

# Create Drush symlink if it doesn't exist
ln -s vendor/bin/drush drush

# Run update and cache clear with Drush
./drush updatedb && ./drush cr

# Navigate back to the project folder
cd ../

# Revert permissions
chown -R www-data: drupal && chmod -R 755 drupal && chmod -R 444 drupal/sites/default/settings.php

# Revert permissions if inside Drupal
chown -R www-data: $(pwd) && chmod -R 755 $(pwd) && chmod -R 444 $(pwd)/sites/default/settings.php
```

These commands cover setting up and managing permissions, installing Composer, running Composer commands, creating Drush symlink, and handling permissions adjustments for Drupal CMS.

># MySQL Command Reference
---


## Access and Database Management

Access MySQL monitor:

```bash
mysql -u [username] -p;  # (will prompt for password)
```

Show all databases:

```bash
show databases;
```

Access a specific database:

```bash
mysql -u [username] -p [database];  # (will prompt for password)
```

Create a new database:

```bash
create database [database];
```

Select a database:

```bash
use [database];
```

Determine the current database:

```bash
select database();
```

## Table Operations

Show all tables in a database:

```bash
show tables;
```

Show table structure:

```bash
describe [table];
```

List all indexes on a table:

```bash
show index from [table];
```

Create a new table with columns:

```bash
CREATE TABLE [table] ([column] VARCHAR(120), [another-column] DATETIME);
```

## Record Manipulation

Insert a record:

```bash
INSERT INTO [table] ([column], [column]) VALUES ('[value]', '[value]');
```

Select all records:

```bash
SELECT * FROM [table];
```

Select specific columns:

```bash
SELECT [column], [another-column] FROM [table];
```

Update records:

```bash
UPDATE [table] SET [column] = '[updated-value]' WHERE [column] = [value];
```

Delete records:

```bash
DELETE FROM [table] WHERE [column] = [value];
```

Delete all records in a table:

```bash
DELETE FROM [table];
```

## Advanced Operations

Export a database dump:

```bash
mysqldump -u [username] -p [database] -h localhost > db_backup.sql;
```

Import a database dump:

```bash
mysql -u [username] -p -h localhost [database] < db_backup.sql;
```

Show all database sizes:

```bash
SELECT table_schema "Database Name", sum(data_length + index_length) / 1024 / 1024 "Database Size (MB)" FROM information_schema.TABLES GROUP BY table_schema;
```

Show table sizes for a database:

```bash
SELECT table_name AS `Table`, round(((data_length + index_length) / 1024 / 1024), 2) `Size (MB)` FROM information_schema.TABLES WHERE table_schema = "[database]";
```

## Tips and Troubleshooting

To handle large dumps:

```bash
mysqldump --max_allowed_packet=512M -u [username] -p -h localhost [database] | gzip > db_backup.sql.gz;
```

If encountering 'Access denied' error during dump:

```bash
mysqldump -u [username] -p [database] -h localhost --column-statistics=0 --no-tablespaces --set-gtid-purged=OFF | gzip > dump.sql.gz;
```

Import from compressed files (GZip, 7z, zip):

```bash
zcat db_backup.sql.gz | mysql -u [username] -p [database] -h localhost;
7z x -so db_backup.sql.7z | mysql -u [username] -p [database] -h localhost;
unzip -p ./db_backup.sql.zip | mysql -u [username] -p [database] -h localhost;
```
Create new database and assign a new user to access new database

```bash
-- Create a new database
CREATE DATABASE IF NOT EXISTS db-name;

-- Switch to the new database
USE db-name;

-- Create a new user and set a password
CREATE USER 'user-name'@'localhost' IDENTIFIED BY 'password-here';

-- Grant privileges to the user for the new database
GRANT ALL PRIVILEGES ON db-name.* TO 'user-name'@'localhost';

-- Grant privileges to a specific IP address
GRANT ALL PRIVILEGES ON db-name.* TO 'user-name'@'10.10.10.10' IDENTIFIED BY 'password-here';

-- Flush privileges to apply the changes
FLUSH PRIVILEGES;

-- Import the database from agzip file
zcat ./sql.gz | mysql -h host-name -u mysql_root -p db-name

-- Import a database from sql file
mysql -h host-name -u mysql_root -p db-name < sql.sql

-- Or use large file from source
mysql -u root -p;
use db-name;
source /var/www/html/sql.sql;

-- Find and replace in gzip file
zcat ./sql.gz | sed 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' > sql.sql
```

## Miscellaneous

Logout from MySQL:

```bash
exit;
```

Export a database dump as GZip:

```bash
mysqldump -u root -p -h localhost [database] | gzip > db_backup.sql.gz;
```

Note: Adjust placeholders like [username], [database], [table], [column], [value], etc., based on your specific setup.

># ZIP Commands
---

## Creating ZIP Archives

Zip files and directories:

```bash
zip archivename.zip filename1 filename2 filename3
```

Zip a folder and its subfolders:

```bash
zip -r archivename.zip directory_name
```

Add multiple files and directories to the same archive:

```bash
zip -r archivename.zip directory_name1 directory_name2 file1 file2
```

Create a password-protected ZIP file:

```bash
zip -e archivename.zip directory_name
```

Split the ZIP archive into 1GB each:

```bash
zip -s 1g -r archivename.zip directory_name
```

Zip everything in the current folder:

```bash
zip archivename.zip *
zip archivename.zip .* *
```

## Extracting ZIP Archives

Unzip a ZIP file:

```bash
unzip latest.zip
```

Unzip a ZIP file to a different directory:

```bash
unzip filename.zip -d /path/to/directory
```

Unzip a password-protected ZIP file:

```bash
unzip -P PasswOrd filename.zip
```

Unzip multiple ZIP files:

```bash
unzip '*.zip'
```

Exclude files when unzipping a ZIP file:

```bash
unzip filename.zip -x file1-to-exclude file2-to-exclude
```

Overwrite existing files without prompting:

```bash
unzip -o filename.zip
```

># GZip Commands
---

## Compression and Decompression

Compress a single file and delete the original:

```bash
gzip file.txt
```

Compress multiple files and delete the originals:

```bash
gzip file1.txt file2.txt file3.txt
```

Compress all text files in the current directory:

```bash
gzip *.txt
```

Compress a single file and keep the original:

```bash
gzip -c file.txt > file.txt.gz
gzip -k file.txt > file.txt.gz
```

Compress all files recursively in the current directory:

```bash
gzip -r *
```

Decompress a gzip compressed file:

```bash
gzip -d file.txt.gz
gunzip file.txt.gz
```

List the content of a compressed file:

```bash
zcat test.txt.gz
```

Search for a pattern in the contents of a compressed file:

```bash
zgrep exa test.txt.gz
```

># TAR Commands
---

## Creating and Extracting TAR Archives

Create a tar archive of files and folders:

```bash
tar -cvzf code.tar.gz ./code
```

Create a tar.gz backup excluding specific folders:

```bash
tar --exclude='/var/www/db-backups' --exclude='/var/www/json_data' \
--exclude='/var/www/vendor' -zcvf code.$(date +'%d%m%Y').tgz /var/www/www.site.in
```

Create a tar.gz backup in a specific folder excluding some folders:

```bash
tar --exclude='./folder' --exclude='./upload' -zcvf /backup/filename.tgz .
```

Extract a tar archive into a folder:

```bash
mkdir sample && tar -xf sample.tar.gz -C ./sample
```

List the contents of a tar archive:

```bash
tar -tvf sample.tar.gz
```

Extract a single file from tar contents:

```bash
tar -xvf sample.tar home.html
tar -zxvf sample.tar.gz home.html
tar -xvf sample.tar "file1" "file2" "..."
tar -xvf sample.tar --wildcards '*.php'
```

Append a file or folder to an existing tar archive:

```bash
tar -rvf sample.tar robots.txt
```

Check the size of a tar file without extracting:

```bash
tar -czf - sample.tar | wc -c
```

Exclude files and directories when creating a tar file:

```bash
tar --exclude='robots.txt' -zcvf backup.tar.gz /home/source
tar --exclude='*.txt' -zcvf backup.tar.gz /home/source
```

Remove a file or directory from a tar archive:

```bash
tar --delete -f backup.tar.gz sample.txt
tar --delete -f backup.tar.gz '/home/source/uploads'
```

># Essential Linux Commands
---

## File and Directory Operations

1. **ls**: List files and directories.

   ```bash
   ls
   ```

2. **pwd**: Print the current working directory.

   ```bash
   pwd
   ```

3. **cd**: Change directory.

   ```bash
   cd folder
   ```

4. **mkdir**: Create directories.

   ```bash
   mkdir fruits
   ```

5. **mv**: Move or rename files and directories.

   ```bash
   mv source _source
   ```

6. **cp**: Copy files and directories.

   ```bash
   cp /backup/settings.php .
   ```

7. **rm**: Remove files or directories.

   ```bash
   rm -rf unused newfolder test backup
   ```

8. **touch**: Create empty files.

   ```bash
   touch README.txt
   ```

9. **ln**: Create symbolic links.

   ```bash
   ln -s ./vendor/bin/drush drush
   ```

## File Content Display and Manipulation

10. **cat**: Display file contents.

    ```bash
    cat filename
    ```

11. **less**: Display paged outputs.

    ```bash
    less long-logs.log
    ```

12. **echo**: Print text.

    ```bash
    echo "Hello, World!"
    ```

## Compression and Archiving

13. **tar**: Create and extract tar archives.

    ```bash
    tar -cvzf archive.tar.gz ./folder
    tar -xvf archive.tar.gz
    ```

14. **gzip**: Compress and decompress files.

    ```bash
    gzip file.txt
    gunzip file.txt.gz
    ```

15. **zip**: Create and extract zip archives.

    ```bash
    zip archive.zip file1 file2
    unzip archive.zip
    ```

## System Information and Management

16. **ps**: Display active processes.

    ```bash
    ps
    ```

17. **top**: View active processes with system usage.

    ```bash
    top
    ```

18. **df**: Display disk filesystem information.

    ```bash
    df
    ```

19. **du**: Display disk usage of files and directories.

    ```bash
    du -h
    ```

20. **uname**: Display basic information about the operating system.

    ```bash
    uname -a
    ```

## Searching and Editing

21. **grep**: Search for patterns in files.

    ```bash
    grep "pattern" filename
    ```

22. **sed**: Stream editor for text transformation.

    ```bash
    sed -i 's|old|new|g' file.txt
    ```

23. **awk**: Pattern scanning and processing language.

    ```bash
    awk '{print $2}' file.txt
    ```

24. **vi or nano**: Text editors for file editing.

    ```bash
    vi filename
    nano filename
    ```

## Networking

25. **ifconfig**: Display network interfaces and IP addresses.

    ```bash
    ifconfig
    ```

26. **traceroute**: Trace network hops to reach a destination.

    ```bash
    traceroute www.example.com
    ```

27. **ssh**: Secure Shell to connect to remote servers.

    ```bash
    ssh user@hostname
    ```

28. **wget**: Download files from the internet.

    ```bash
    wget https://www.example.com/file.zip
    ```

## System Administration

29. **sudo**: Execute commands with elevated privileges.

    ```bash
    sudo command
    ```

30. **ufw**: Uncomplicated Firewall for managing iptables.

    ```bash
    ufw allow 80
    ```

31. **apt, yum, pacman**: Package managers for installing software.

    ```bash
    apt install package
    ```

32. **systemctl**: Control the systemd system and service manager.

    ```bash
    systemctl start service
    ```

33. **crontab**: Schedule periodic tasks.

    ```bash
    crontab -e
    ```

These are fundamental Linux commands for everyday use, covering file operations, system information, compression, networking, and system administration. Explore and practice them to become proficient in Linux.

># Amazon Linux 2 PHP 8.1 installation
---

Your provided script appears to be a step-by-step guide for installing and configuring PHP 8.1 on Amazon Linux 2. It covers a range of tasks, including checking installed PHP versions, enabling and disabling PHP versions, installing utility tools, installing PHP extensions, configuring PHP-FPM, and more. Here's a summary of the key steps:

1. Find and remove existing PHP versions:

   ```bash
   yum list installed | grep php
   amazon-linux-extras | grep php
   amazon-linux-extras install php8.1
   yum remove php*
   ```

2. Install and enable repositories:

   ```bash
   yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
   yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
   ```

3. Disable PHP 7.4 and enable PHP 8.1:

   ```bash
   amazon-linux-extras disable php7.4
   yum-config-manager --enable remi-php81
   amazon-linux-extras enable php8.1
   ```

4. Clean yum cache and install PHP 8.1:

   ```bash
   yum makecache
   yum clean metadata
   yum install php
   ```

5. Install PHP extensions and other tools:

   ```bash
   yum install php-{pear,cgi,pdo,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imagick,mcrypt:}
   ```

6. Restart PHP-FPM service:

   ```bash
   service php-fpm restart
   ```

7. Check installed PHP version:

   ```bash
   php -v
   ```

8. Install additional PHP tools and extensions:

   ```bash
   yum install php-pear php-devel
   pecl install imagick
   ```

9. Restart services (PHP-FPM, Nginx, or Apache):

   ```bash
   systemctl restart php-fpm.service
   service nginx reload
   service httpd reload
   ```

10. Verify services and system status:

    ```bash
    systemctl status php-fpm.service
    systemctl status nginx.service
    df -h
    du -sh
    ```

11. Update and check system packages:

    ```bash
    yum check-update
    ```

12. Miscellaneous commands:

    ```bash
    locate beauty-and-beast
    ls -lhrt
    tail -f /opt/www-site-com/log/error.log
    ```

These steps provide a comprehensive guide for setting up PHP 8.1 on Amazon Linux 2. Please ensure that you adapt the script to your specific server environment and requirements.

># Essential Git Commands
---

## Project Setup and Git Commands

This section provides instructions on setting up a project with Git and includes commands for managing branches, merging changes, resolving conflicts, and deleting remote branches or files if committed.

## Setup a Project with Git

```bash
# Initialize a new Git project in a folder called hello-git
cd hello-git
git init
git config user.name "Your Name"
git config user.email "Your Email"
git remote add origin https://github.com/My-Website/Frontend.git

# To check existing origin and URL
git remote -v

# To update the existing URL
git remote set-url origin <new-url.git>

# Here, origin is the alias name for your added URL. You can use multiple URLs and aliases like:
git remote add github <github-url>
git remote add bitbucket <bitbucket-url>

# To use them, you have to explicitly call and mention the alias. For example:
git checkout -b dev
git pull github dev

# And for bitbucket:
git checkout -b master
git pull bitbucket master

# To switch branches, use the following command:
git switch <branch>
```

## Using git merge

```bash
# If you're already in a conflicted state and need to fix a single file:
git checkout --theirs /web/public/js/master.js
# '/web/public/js/master.js' is the file where you have many conflicts, and you want to accept the dev file.

# At any time, if you feel that the merge was executed accidentally, you can use:
git merge --abort
git reset --merge
git reset --hard
git reset --hard HEAD@{1}
# These commands will take you back to the previous state where your branch was happy (HEAD).

# HEAD is a state where you have no pending commits, and your branch is up to date with no local changes.
```

## Delete a Remote Branch

```bash
# Deleting local branch
git branch -D <my-branch>

# Deleting remote branch
git push -d origin <my-branch>
```

## Delete a file if committed

## Using BFG (Java Runtime Required)

1. Download the BFG tool from [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/).
2. Create a separate folder (e.g., 'cleaner') as a backup.
3. Clone the Git repository into the 'cleaner' folder.
4. Change directory to the cloned repository.
5. Copy the downloaded 'bfg-1.14.0.jar' into the repository folder.
6. Check the current branch (`git branch`).
7. Run the following commands:

```bash
# Checkout to the master branch
git checkout master

# Run BFG to delete a sensitive file (e.g., 'azdeploy.sh')
java -jar bfg-1.14.0.jar .git --delete-files "azdeploy.sh"

# Expire git ref logs
git reflog expire --expire=now --all

# Run Git Garbage Collection (prune)
git gc --prune=now --aggressive

# Force update remote with new history
git push origin --force --all
```

## Using Git Native Commands

```bash
# Run Git filter-branch to remove the file (e.g., 'azdeploy.sh')
git filter-branch -f --tree-filter 'rm -f azdeploy.sh' HEAD

# Update refs
git update-ref -d refs/original/refs/heads/<branch-name>

# Expire git ref logs
git reflog expire --expire=now --all

# Run Git Garbage Collection (prune)
git gc --prune=now
```

Please note that these commands should be used with caution, especially when force-pushing changes to a remote repository, as it can overwrite existing history. Ensure you have a backup of your repository before performing such operations.

># AWS CLI Commands
---

```bash
# AWS S3 Commands

# I want to delete all .DS_STORE files from everywhere in bucket

aws s3 rm s3://myaws-s3/backups/ --recursive --exclude "*" --include "*.DS_Store" --dryrun

# --dryrun will execute the command but not in real, hence once changes are correct, run again

aws s3 rm s3://myaws-s3/backups/ --recursive --exclude "*" --include "*.DS_Store"

# I want to sync my local images folder from S3 bucket folder

aws s3 sync s3://myaws-s3/backups/images/ /var/www/html/www-site-com/web/images/

# Copying local sql dump backup on to s3 folder

aws s3 cp ./dump-$(date +%Y%m%d%H%M%S).sql.gz s3://myaws-s3/backups/sqldump/
```

># FFMPEG Commands
---

```bash
# WebM to MP4:
ffmpeg -i xss.webm -strict experimental video.mp4
ffmpeg -i xss.webm -movflags faststart -profile:v high -level 4.2 xss.mp4

# MP4 to Image:
ffmpeg -i video.mp4 -r 1/1 $filename%03d.jpg
```

># OpenSSL Commands
---

```bash
# Encrypt: Use openssl to encrypt the file:
openssl aes-256-cbc -a -salt -in secrets.txt -out secrets.txt.enc

# Decrypt: Use openssl to decrypt the file:
openssl aes-256-cbc -d -a -in secrets.txt.enc -out secrets.txt.new

# Integrate Subresource Integrity Check
openssl dgst -sha384 -binary README.md | openssl base64 -A
```

># Nginx Drupal settings
---

```bash
# -----------------------------------------------
# Default server configuration www.example.com
# -----------------------------------------------

# Redirecting https://site.com to https://www.site.com
server {
listen 8080;
server_name example.com;
#return 301 $scheme://www.$host$request_uri;
return 301 https://www.example.com$request_uri;
}

# Main server block
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;

    # root folder path
    root /var/www/html/www-example-com/web;

    # Add index.php to the list if you are using PHP
    index index.php index.html index.htm index.nginx-debian.html;

    # server name
    server_name www.example.com g65rteds43szmu.cloudfront.net;
    #return 301 $scheme://www.example.com$request_uri;

    # access and error log
    access_log /var/log/www-example-com/access/access.log combined;
    error_log /var/log/www-example-com/error/error.log;

    # Setting a var for site name
    set $mysite https://www.example.com;

    # Removing trailing slash and 301 redirect
    rewrite ^(.+)/+$ $mysite$1 permanent;

    # Remove ?amp parameter
    if ($args ~* "/?amp") {
        return 301 https://$host$uri;
    }

    # general settings
    charset UTF-8;
    sendfile on;
    tcp_nopush on;
    server_tokens off;
    autoindex on;
    client_max_body_size 65M;
    client_body_buffer_size 12k;
    client_header_buffer_size 1k;
    large_client_header_buffers 2 4k;

    # gzip compression settings
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied expired no-cache no-store private auth;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/x-javascript application/xml;

    # Essential Security Headers
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options nosniff;
    add_header Referrer-Policy "strict-origin";
    add_header Permissions-Policy "interest-cohort=()";
    add_header Strict-Transport-Security "max-age=31536000";
    add_header Content-Security-Policy "upgrade-insecure-requests";
    add_header X-Content-Type-Options nosniff;
    add_header Source-Monitoring launcher01;
    add_header Access-Control-Allow-Origin *;

    # allow only GET, HEAD and POST
    if ($request_method !~ ^(GET|HEAD|POST)$ ) {
        return 444;
    }

    # Custom 401 web auth page
    error_page 401 /401.html;
    location = /401.html {
        root /var/www/html/www-example-com;
        internal;
    }

    # Custom 4xx error
    #error_page 403 404 /4xx.html;
    #location = /4xx.html
    #{
    # root /var/www/html/www-example-com;
    # internal;
    #}

    # Custom 5xx error
    error_page 500 502 503 504 /5xx.html;
    location = /5xx.html {
        root /var/www/html/www-example-com;
        internal;
    }

    # favicon 404 off
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    # SEO robots.txt
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Prevent unauthorized execution
    location ~ \..*/.*\.php$ {
        return 403;
    }

    # Prevent unauthorized execution
    location ~ ^/sites/.*/private/ {
        return 403;
    }

    # Block access to scripts in site files directory
    location ~ ^/sites/[^/]+/files/.*\.php$ {
        deny all;
    }

    #Allow "Well-Known URIs" as per RFC 5785
    location ~* ^/.well-known/ {
        allow all;
    }

    # Web auth for Drupal CMS admin login
    location /user {
        auth_basic "Restricted Content";
        auth_basic_user_file /var/www/html/www-example-com/.htpasswd;
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Block     access to "hidden" files and directories whose names begin with a
    # period.   This includes directories used by version control systems such
    # as        Subversion or Git to store control files.
    location ~ (^|/)\. {
        return 403;
    }

    # Don't allow direct access to PHP files in the vendor directory.
    location ~ /vendor/.*\.php$ {
        deny all;
        return 404;
    }

    # Protect files and directories from prying eyes.
    location ~* \.(engine|inc|install|make|module|profile|po|sh|.*sql|theme|twig|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|^(\.( ?!well-known).*|Entries.*|Repository|Root|Tag|Template|composer\.(json|lock)|web\.config)$|^#.*#$|\.php(~|\.sw[op]|\.bak|\.orig|\.save)$ {
        deny all;
        return 404;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|webp|ico|svg|woff|woff2|mp4|webm)$ {
        try_files $uri @rewrite;
        expires max;
        log_not_found off;
    }
    # Fighting  with Styles? This little gem is amazing.
    # location ~ ^/sites/.*/files/imagecache/ { # For Drupal <= 6
    location ~ ^/sites/.*/files/styles/ {
        try_files $uri @rewrite;
    }

    # Handle    private files through Drupal. Private file's path can come
    # with      a language prefix.
    # location ~ ^(/[a-z\-]+)?/system/files/ { # For Drupal >= 7
    location ~ ^(/[a-z\-]+)?/system/files/ {
        try_files $uri /index.php?$query_string;
    }

    # Enforce   clean URLs
    # Removes   index.php from urls like www.example.com/index.php/my-page www.example.com/my-page
    # Could     be done with 301 for permanent or other redirect codes.
    if ($request_uri ~* "^(.*/)index\.php/(.*)") {
        return 307 $1$2;
    }

    location / {
        # Disable directory listing
        autoindex off;
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        # try_files $uri $uri/ =404;
        try_files $uri $uri/ /index.php?$query_string;
        # Fixing Cloudfront 504 issue
        proxy_read_timeout 3600;
    }

    location @rewrite {
        #rewrite ^/(.*)$ /index.php?q=$1; # For Drupal <= 6
        rewrite ^ /index.php; # For Drupal >= 7
    }

    # pass PHP scripts to FastCGI server
    #
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;

        # try_files $fastcgi_script_name =404;

        fastcgi_param HTTP_PROXY "";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;

        # Proxy settings FastCGI
        fastcgi_connect_timeout 120;
        fastcgi_send_timeout 120;
        fastcgi_read_timeout 120;

        # With php-fpm (or other unix sockets):
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    # SSL configuration
    #
    # listen 443 ssl default_server;
    # listen [::]:443 ssl default_server;
    #
    # Note: You should disable gzip for SSL traffic.
    # See: https://bugs.debian.org/773332
    #
    # Read up on ssl_ciphers to ensure a secure configuration.
    # See: https://bugs.debian.org/765782
    #
    # Self signed certs generated by the ssl-cert package
    # Don't use them in a production server!
    #
    # include snippets/snakeoil.conf;
}
```

># PHP FPM | INI config
---

```bash
# Ubuntu Custom PHP INI Path /etc/php/{version}/fpm/conf.d/custom.ini

[PHP]
memory_limit=256M
upload_max_filesize=20M
post_max_size=25M
max_execution_time=30
display_errors=off
date.timezone=Asia/Kolkata
error_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT
magic_quotes_gpc=off
allow_url_fopen=on
allow_url_include=off
max_input_time=30
disable_functions=exec,passthru,shell_exec,system,popen
asp_tags=off
display_startup_errors=off
engine=on
expose_php=off
ignore_repeated_errors=off
implicit_flush=off
Log_errors_max_len=1024
log_errors=on
mysqlnd.collect_memory_statistics=off
mysqlnd.collect_statistics=off
opcache.enable=1
opcache.jit_buffer_size=100M
output_buffering=4096
realpath_cache_size=512k
realpath_cache_ttl=300
serialize_precision=17
short_open_tag=on
unserialize_callback_func=
zend.enable_gc=on
```
