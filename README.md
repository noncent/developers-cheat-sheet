<img src="./welcome-600x300.jpg" alt="Noncent" width="100%">

<br/><br/>

> # Git Pull Error - "RPC failed; curl 18 transfer closed with outstanding read data remaining" (13 April 2024)

**Error Message:**

```
remote: Enumerating objects: 25820, done.
remote: Counting objects: 100% (1078/1078), done.
remote: Compressing objects: 100% (703/703), done.
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
error: 53384 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
fatal: fetch-pack: invalid index-pack output
```

**Solution:**

**1. Turn off Compression:**

```bash
git config --global core.compression 0
```

**2. Adjust HTTP Post Buffer:**

```bash
git config --global http.postBuffer 2M
```

**3. Perform a Partial Clone:**

```bash
git clone --depth 1 <repo_URI>
```

**4. Retrieve the Rest of the Clone:**

```bash
cd <repo_directory>
git fetch --unshallow 
```

or 

```bash
git fetch --depth=2147483647
```

**5. Regular Pull:**

```bash
git pull --all
```

**Additional Solutions:**

- **Memory Configuration:**

```bash
# File path ~/.gitconfig

[core] 
    packedGitLimit = 512m 
    packedGitWindowSize = 512m 
[pack] 
    deltaCacheSize = 2047m 
    packSizeLimit = 2047m 
    windowMemory = 2047m
```

**Or**

```bash
# File path ~/.gitconfig

[core] 
packedGitLimit = 512m 
packedGitWindowSize = 512m 
[pack] 
deltaCacheSize = 2047m 
packSizeLimit = 2047m 
windowMemory = 2047m
```

- **HTTP Version Configuration:**

```bash
git config --global http.version HTTP/1.1
```

- **Adjusting Depth for Large Projects:**

```bash
git pull --depth=1 {repo} {branch}
```

**Note:** Some users reported issues on macOS Big Sur and resolved them by running:
```bash
ulimit -n unlimited
ulimit -f unlimited
```

These solutions should help resolve the "RPC failed; curl 18 transfer closed with outstanding read data remaining" error during `git pull` operations. If the problem persists, further troubleshooting may be required.


> # MacOS: Valid Self-Signed SSL Certificate (10 Marh 2024)



This guide outlines the process of creating and configuring a self-signed SSL certificate on MacOS using the `minica` tool. This certificate setup is compatible with both Firefox and Chrome browsers.

## Prerequisites

Before proceeding, ensure you have the following:

- MacOS system
- Basic knowledge of terminal commands
- `minica` tool installed (can be downloaded from [here](https://github.com/jsha/minica))

## Step 1: Install `minica`

You can install `minica` by following these steps:

1. Visit the [minica GitHub repository](https://github.com/jsha/minica).
2. Download and install the tool according to the instructions provided.
    - Alternatively, if you have Homebrew installed, you can use the command `brew install minica` to install it.

## SSL Certificate Generation

To create a self-signed SSL certificate using `minica`, follow these steps:

1. **Installation**: Ensure `minica` is installed on your system.

2. **Command Execution**:
   - Open your terminal.
   - Execute the command `minica --domains "*.development.dev"`.
     - This command generates a wildcard SSL certificate valid for all subdomains under `.development.dev`, such as `site.development.dev`, `cms.development.dev`, etc.

3. **Certificate Location**:
   - After executing the command, you'll find two files, `cert.pem` and `key.pem`, inside the `_.development.dev` folder. This folder is created in the same location where you executed the command.
   - For wildcard certificates, the folder will be named `_.{your wildcard domain name}`. For example, for the domain `cms.example.com`, it will be `cms.example.com`.

4. **Additional Files**:
   - Alongside, two more files named `minica-key.pem` and `minica.pem` are generated. `minica.pem` needs to be added to your system's Keychain Access on macOS or [Windows](https://gist.github.com/mwidmann/115c2a7059dcce300b61f625d887e5dc) or [Linux](https://gist.github.com/mwidmann/115c2a7059dcce300b61f625d887e5dc) .

5. **Adding to Keychain Access**:
   - macOS users can add `minica.pem` using the command: `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /my/path/to/minica.pem`.
   - Alternatively, import the file directly using 'File >> Import items'.

6. **Verification**:
   - Once added, open 'Keychain Access', and search for 'minica'.
   - Locate the certificate with an error icon (not marked as a blue plus sign).
   - Double-click on the file, click 'Trust' >> 'Always Trust', then close the dialog box and 'Keychain Access'.
   - Reopen 'Keychain Access' and search to verify if the certificate was successfully added.

7. **Completion**:
   - With these steps, each browser will accept the certificate for your domain without any errors or exceptions.

## Step 3: Configure Web Server

You can use the generated `cert.pem` and `key.pem` files to configure your web server (e.g., Apache or Nginx) to enable HTTPS locally.

### Example Nginx Configuration

**nginx.conf:**

```nginx
# Define the number of worker connections for Nginx events
events {
    worker_connections 1024;
}

# Nginx HTTP configuration block
http {
    # Include MIME types configuration
    include mime.types;

    # Set the default MIME type for files with unknown extensions
    default_type application/octet-stream;

    # Define the log format for access logs
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';

    # Configure access and error logs
    access_log /usr/local/var/www/logs/access.log main;
    error_log /usr/local/var/www/logs/error.log;

    # Enable sendfile for efficient file transfers
    sendfile on;

    # Enable TCP_NOPUSH and TCP_NODELAY to optimize TCP connections
    tcp_nopush on;
    tcp_nodelay on;

    # Set the maximum size of hash tables for types
    types_hash_max_size 2048;

    # Enhance security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # Disable server signature
    server_tokens off;

    # Enable gzip compression
    gzip on;
    gzip_disable "msie6";

    # Specify the root directory and default index files
    root /usr/local/var/www;
    index index.php index.html;

    # Server block for HTTPS
    server {
        listen 443 ssl;
        server_name local.dev.com;

        # Include SSL configuration
        include ssl.conf;

        # Enforce HTTPS and non-www
        if ($scheme != "https") {
            return 301 https://$host$request_uri;
        }
        if ($host = www.local.dev.com) {
            return 301 https://local.dev.com$request_uri;
        }

        # Location block for handling requests
        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            # include snippets/fastcgi-php.conf;
            fastcgi_pass 127.0.0.1:9000; # Adjust the PHP version and socket path as needed
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        # Add secure headers for assets (optional)
        location ~* \.(css|js|jpg|jpeg|gif|png|ico)$ {
            add_header Cache-Control "public, max-age=31536000, immutable";
            add_header Expires "Sat, 30 Oct 2021 14:00:00 GMT";
            try_files $uri =404;
        }

        # Disable unnecessary logs for assets
        location ~* \.(css|js|jpg|jpeg|gif|png|ico)$ {
            access_log off;
            log_not_found off;
        }

        # Deny access to sensitive files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
    }

    # Include additional server configurations from the 'servers' directory
    include servers/*;
}
```

**ssl.conf:**

```nginx
# the cert files and key location
ssl_certificate /usr/local/var/www/.ssl/_.development.dev/cert.pem;
ssl_certificate_key /usr/local/var/www/.ssl/_.development.dev/key.pem;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;

# Enable SSL session cache for improved performance
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# Enable advanced SSL security settings
ssl_protocols TLSv1.2 TLSv1.3;
```

### Important

* Replace paths and configurations in the above examples as per your setup.
* Do not forget to restart your nginx web server
* Do not forget to open the cert.pen in keychain and mark them as trusted all

## Conclusion

Following these steps, you can set up a valid self-signed SSL certificate on MacOS using `minica`, ensuring compatibility with Firefox and Chrome browsers.

<br/>
<br/>

> # Essential Drupal Commands


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

## Bonus drush commands!
:bulb:
>- Open MySQL terminal <code>./drush sql-cli</code>
>- Import sql file <code>./drush sql-cli < path/to/your/sql/file.sql</code>
>- Export sql file <code>./drush sql-dump > path/to/your/exported/db.sql</code>

These commands cover setting up and managing permissions, installing Composer, running Composer commands, creating Drush symlink, and handling permissions adjustments for Drupal CMS.

<br/><br/>

> # MySQL Command Reference



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

-- Decompress the gzip file using zcat, apply sed, and compress back into gzip
zcat "file.gz" | sed "s/find/replace/g" | gzip > "file.gz"
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

<br/><br/>

> # ZIP Commands


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

<br/><br/>

> # GZip Commands


## Compression and Decompression

**Compress a Single File and Delete the Original** (`gzip`):
```bash
gzip file.txt
```
- `gzip`: Compresses the specified file using gzip compression.
- `file.txt`: The file you want to compress. After compression, the original file is replaced with the compressed file `file.txt.gz`.

**Compress Multiple Files and Delete the Originals** (`gzip`):
```bash
gzip file1.txt file2.txt file3.txt
```
- `gzip`: Compresses multiple files using gzip compression.
- `file1.txt file2.txt file3.txt`: The files you want to compress. After compression, the original files are replaced with their respective compressed files.

**Compress All Text Files in the Current Directory** (`gzip`):
```bash
gzip *.txt
```
- `gzip`: Compresses all files with the `.txt` extension in the current directory using gzip compression.

**Compress a Single File and Keep the Original** (`gzip -c` or `gzip -k`):
```bash
gzip -c file.txt > file.txt.gz
```
or
```bash
gzip -k file.txt > file.txt.gz
```
- `-c`: Writes the compressed output to standard output without changing the original file.
- `-k`: Keeps the original file after compression.
- `file.txt`: The file you want to compress.
- `file.txt.gz`: The compressed output file.

**Compress All Files Recursively in the Current Directory** (`gzip -r`):
```bash
gzip -r *
```
- `-r`: Recursively compresses all files and directories in the current directory using gzip compression.

**Decompress a Gzip Compressed File** (`gzip -d` or `gunzip`):
```bash
gzip -d file.txt.gz
```
or
```bash
gunzip file.txt.gz
```
- `-d`: Decompresses the specified gzip compressed file.
- `file.txt.gz`: The gzip compressed file you want to decompress.

**List the Contents of a Compressed File** (`zcat`):
```bash
zcat test.txt.gz
```
- `zcat`: Concatenates and displays the contents of a gzip compressed file.
- `test.txt.gz`: The gzip compressed file whose contents you want to display.

**Search for a Pattern in the Contents of a Compressed File** (`zgrep`):
```bash
zgrep exa test.txt.gz
```
- `zgrep`: Searches for a pattern in the contents of a gzip compressed file.
- `exa`: The pattern you want to search for.
- `test.txt.gz`: The gzip compressed file you want to search within.

**Concatenate and Display Gzipped Files** (`zcat`):
```bash
zcat file.txt.gz
```
- `zcat`: Concatenates and displays the contents of gzipped files.
- `file.txt.gz`: The gzipped file you want to display.

**Compress a File with Gzip** (`gzip`):
```bash
gzip file.txt
```
- `gzip`: Compresses files using gzip compression.
- `file.txt`: The file you want to compress. After compression, the original file is replaced with the compressed file `file.txt.gz`.

**Decompress a Gzipped File** (`gzip -d` or `gunzip`):
```bash
gzip -d file.txt.gz
```
or
```bash
gunzip file.txt.gz
```
- `-d`: Decompresses files.
- `file.txt.gz`: The gzipped file you want to decompress.

**Create a Zip Archive** (`zip`):
```bash
zip -r archive.zip directory
```
- `-r`: Recursively includes all files and directories within the specified directory.
- `archive.zip`: The name of the zip archive you want to create.
- `directory`: The directory you want to include in the zip archive.

**Extract a Zip Archive** (`unzip`):
```bash
unzip archive.zip
```
- `unzip`: Extracts files from a zip archive.
- `archive.zip`: The zip archive you want to extract.

**List Contents of a Zip Archive** (`unzip -l`):
```bash
unzip -l archive.zip
```
- `-l`: Lists contents of the zip archive.
- `archive.zip`: The zip archive whose contents you want to list.

These commands allow you to work with gzip and zip archives, including displaying the contents of gzipped files, compressing and decompressing files with gzip, creating and extracting zip archives, and listing the contents of zip archives.

<br/><br/>

> # TAR Commands

There are various commands and options you can use with the `tar` utility in Unix-like operating systems. Here are some of the most commonly used `tar` commands along with their options:

1. **Create a Tar Archive**:
   ```
   tar -cvf archive.tar file1 file2 directory
   ```
   - `-c`: Create a new archive.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

2. **Extract Tar Archive**:
   ```
   tar -xvf archive.tar
   ```
   - `-x`: Extract files from an archive.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

3. **List Contents of Tar Archive**:
   ```
   tar -tvf archive.tar
   ```
   - `-t`: List the contents of an archive.
   - `-v`: Verbose mode (show file details).
   - `-f`: Specify the archive file name.

4. **Append Files to Existing Tar Archive**:
   ```
   tar -rvf archive.tar file3 file4
   ```
   - `-r`: Append files to an archive.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

5. **Extract Specific Files from Tar Archive**:
   ```
   tar -xvf archive.tar file1 file2
   ```
   This command extracts only `file1` and `file2` from the `archive.tar` archive.

6. **Compress Tar Archive with gzip**:
   ```
   tar -cvzf archive.tar.gz file1 file2 directory
   ```
   - `-z`: Compress the archive with gzip.
   - `-f`: Specify the archive file name.

7. **Compress Tar Archive with bzip2**:
   ```
   tar -cvjf archive.tar.bz2 file1 file2 directory
   ```
   - `-j`: Compress the archive with bzip2.
   - `-f`: Specify the archive file name.

8. **Extract Tar Archive with gzip**:
   ```
   tar -xvzf archive.tar.gz
   ```
   - `-z`: Extract a gzip-compressed archive.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

9. **Extract Tar Archive with bzip2**:
   ```
   tar -xvjf archive.tar.bz2
   ```
   - `-j`: Extract a bzip2-compressed archive.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

10. **Exclude the folders while creating the tar gzip**:

```bash
tar --exclude='/var/www/.git' --exclude='/var/www/backup' \
--exclude='/var/www/vendor' -czvf code.$(date +'%d%m%Y').tgz /var/www/www.site.in
```
   - `-c`: Create a new archive.
   - `-z`: Compress the archive with gzip.
   - `-v`: Verbose mode (show progress).
   - `-f`: Specify the archive file name.

Here, we have excluded the `.git` folder and `backup` folder during the gzip creation

11. **Create a Tar Archive with gzip Compression and Exclude Certain Folders**:
```bash
tar --exclude='./folder' --exclude='./upload' -zcvf /backup/filename.tgz .
```

- `--exclude='./folder' --exclude='./upload'`: Excludes the `folder` and `upload` directories from the backup.
- `-z`: Compress the archive with gzip.
- `-c`: Create a new archive.
- `-v`: Verbose mode (show progress).
- `-f`: Specify the archive file name.
- `/backup/filename.tgz`: The path and name of the backup file. Adjust this to your desired location and filename.
- `.`: Indicates the current directory, meaning the command creates a backup of the current directory and its contents.

This command creates a tar archive with gzip compression, excluding the specified folders (`folder` and `upload`), and saves it to the `/backup` directory with the filename `filename.tgz`.

12. **Extract a Tar Archive into a Folder**:
```bash
mkdir sample && tar -xf sample.tar.gz -C ./sample
```
- `mkdir sample`: Creates a new directory named `sample`.
- `tar -xf sample.tar.gz -C ./sample`: Extracts the contents of `sample.tar.gz` into the `sample` directory.
  - `-x`: Extract files from the archive.
  - `-f`: Specify the archive file name.
  - `-C ./sample`: Extract files into the `sample` directory.

13. **List the Contents of a Tar Archive**:
```bash
tar -tvf sample.tar.gz
```
- `-t`: List the contents of the archive.
- `-v`: Verbose mode (show file details).
- `-f`: Specify the archive file name.

14. **Extract a Single File from Tar Contents**:
```bash
tar -xvf sample.tar home.html
tar -zxvf sample.tar.gz home.html
tar -xvf sample.tar "file1" "file2" "..."
tar -xvf sample.tar --wildcards '*.php'
```
- `-x`: Extract files from the archive.
- `-v`: Verbose mode (show progress).
- `-f`: Specify the archive file name.
- `-z`: Decompress the archive with gzip.
- `--wildcards '*.php'`: Extract files matching the wildcard pattern `*.php`.

15. **Append a File or Folder to an Existing Tar Archive**:
```bash
tar -rvf sample.tar robots.txt
```
- `-r`: Append files to the archive.
- `-v`: Verbose mode (show progress).
- `-f`: Specify the archive file name.

16. **Check the Size of a Tar File without Extracting**:
```bash
tar -czf - sample.tar | wc -c
```
- `-c`: Write to standard output instead of a file.
- `-z`: Compress the archive with gzip.
- `wc -c`: Count the number of bytes in the output.

17. **Exclude Files and Directories When Creating a Tar File**:
```bash
tar --exclude='robots.txt' -zcvf backup.tar.gz /home/source
tar --exclude='*.txt' -zcvf backup.tar.gz /home/source
```
- `--exclude='robots.txt'`: Exclude the `robots.txt` file from the backup.
- `--exclude='*.txt'`: Exclude all files with the `.txt` extension from the backup.

18. **Remove a File or Directory from a Tar Archive**:
```bash
tar --delete -f backup.tar.gz sample.txt
tar --delete -f backup.tar.gz '/home/source/uploads'
```
- `--delete`: Remove files from the archive.
- `-f`: Specify the archive file name.

These commands cover a range of common tasks when working with tar archives in Unix-like systems.

<br/><br/>

> # Essential Linux Commands


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

**tar**: Create and extract tar archives.
```bash
tar -cvzf archive.tar.gz ./folder
```
- `-c`: Create a new archive.
- `-v`: Verbose mode (show progress).
- `-z`: Compress the archive with gzip.
- `-f archive.tar.gz`: Specify the archive file name.
- `./folder`: The directory you want to include in the tar archive.

```bash
tar -xvf archive.tar.gz
```
- `-x`: Extract files from the archive.
- `-v`: Verbose mode (show progress).
- `-f archive.tar.gz`: Specify the archive file name.

**gzip**: Compress and decompress files.
```bash
gzip file.txt
```
- Compresses the file `file.txt` and replaces it with `file.txt.gz`.

```bash
gunzip file.txt.gz
```
- Decompresses the file `file.txt.gz` and replaces it with `file.txt`.

**zip**: Create and extract zip archives.
```bash
zip archive.zip file1 file2
```
- Creates a zip archive named `archive.zip` containing `file1` and `file2`.

```bash
unzip archive.zip
```
- Extracts files from the zip archive `archive.zip`.


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

Here are several examples of different `grep` commands for various use cases:

1. **Search for a Pattern in a File GREP**:

```bash
grep pattern file.txt
```
- Searches for the specified `pattern` in the `file.txt`.

2. **Case-Insensitive Search**:
```bash
grep -i pattern file.txt
```
- Performs a case-insensitive search for the specified `pattern` in the `file.txt`.

3. **Search for a Pattern in Multiple Files**:
```bash
grep pattern file1.txt file2.txt
```
- Searches for the specified `pattern` in `file1.txt` and `file2.txt`.

4. **Recursive Search in a Directory**:
```bash
grep -r pattern directory
```
- Searches for the specified `pattern` recursively in all files within the `directory`.

5. **Search for a Pattern with Line Numbers**:
```bash
grep -n pattern file.txt
```
- Displays line numbers along with the lines containing the `pattern` in the `file.txt`.

6. **Display Matching Lines Only**:
```bash
grep -o pattern file.txt
```
- Displays only the matched parts of the lines containing the `pattern` in the `file.txt`.

7. **Count the Number of Matching Lines**:
```bash
grep -c pattern file.txt
```
- Counts the number of lines containing the `pattern` in the `file.txt`.

8. **Invert Match (Exclude Lines Matching Pattern)**:
```bash
grep -v pattern file.txt
```
- Displays lines that do not contain the `pattern` in the `file.txt`.

9. **Search for Whole Words Only**:
```bash
grep -w pattern file.txt
```
- Searches for whole words matching the `pattern` in the `file.txt`.

10. **Search for Lines Starting with a Pattern**:
```bash
grep -w "^pattern" file.txt
```
- Searches for lines starting with the specified `pattern` in the `file.txt`.

11. **Search for Lines Ending with a Pattern**:
```bash
grep -w "pattern$" file.txt
```
- Searches for lines ending with the specified `pattern` in the `file.txt`.

12. **Search for Multiple Patterns**:
```bash
grep -E "pattern1|pattern2" file.txt
```
- Searches for lines containing either `pattern1` or `pattern2` in the `file.txt`.

13. **List Files Containing a Pattern** (`grep -l`):
```bash
grep -l pattern file1.txt file2.txt
```
- `grep`: Searches for lines containing the specified `pattern`.
- `-l`: Lists only the names of files that contain at least one match for the pattern.
- `pattern`: The pattern you want to search for.
- `file1.txt file2.txt`: The files in which you want to search for the pattern. If multiple files are provided, `grep` will list only the names of files that contain a match.

These are some common `grep` commands with different options to perform various types of pattern matching and text searching tasks in Unix-like systems.

### Here are various common usages of the `sed` command with explanations:


**sed**: Stream editor for text transformation.


1. **Substitute Text in a File**:
```bash
sed 's/old_text/new_text/' file.txt
```
- `s`: Substitute command.
- `old_text`: The text to be replaced.
- `new_text`: The text to replace `old_text`.
- `file.txt`: The file in which to perform the substitution.

2. **Substitute Text Globally**:
```bash
sed 's/old_text/new_text/g' file.txt
```
- `g`: Global flag, replaces all occurrences of `old_text` with `new_text` in each line of `file.txt`.

3. **Substitute Text Only on Specific Lines**:
```bash
sed '3s/old_text/new_text/' file.txt
```
- Replaces `old_text` with `new_text` only on line 3 of `file.txt`.

4. **Substitute Text Within a Range of Lines**:
```bash
sed '2,5s/old_text/new_text/' file.txt
```
- Replaces `old_text` with `new_text` on lines 2 to 5 of `file.txt`.

5. **Substitute Text and Write Changes to a New File**:
```bash
sed 's/old_text/new_text/' file.txt > new_file.txt
```
- Writes the modified contents to `new_file.txt` instead of modifying `file.txt` directly.

6. **In-Place Editing (Modify File Directly)**:
```bash
sed -i 's/old_text/new_text/' file.txt
```
- `-i`: In-place editing, modifies `file.txt` directly.

7. **Delete Lines Containing a Pattern**:
```bash
sed '/pattern/d' file.txt
```
- Deletes lines containing the specified `pattern` from `file.txt`.

8. **Delete Blank Lines**:
```bash
sed '/^$/d' file.txt
```
- Deletes blank lines from `file.txt`.

9. **Append Text to the End of Each Line**:
```bash
sed 's/$/ new_text/' file.txt
```
- Appends `new_text` to the end of each line in `file.txt`.

10. **Insert Text at the Beginning of Each Line**:
```bash
sed 's/^/new_text /' file.txt
```
- Inserts `new_text` at the beginning of each line in `file.txt`.

11. **Print Specific Line or Lines**:
```bash
sed -n '3p' file.txt
```
- `-n`: Suppresses automatic printing.
- `3p`: Prints line 3 from `file.txt`.

12. **Print Lines Within a Range**:
```bash
sed -n '2,5p' file.txt
```
- Prints lines 2 to 5 from `file.txt`.

These are some common usages of the `sed` command for text manipulation in Unix-like systems.

13. **awk**: Pattern scanning and processing language.

    ```bash
    awk '{print $2}' file.txt
    ```

14. **vi or nano**: Text editors for file editing.

    ```bash
    vi filename
    nano filename
    ```

## Networking

15. **ifconfig**: Display network interfaces and IP addresses.

    ```bash
    ifconfig
    ```

16. **traceroute**: Trace network hops to reach a destination.

    ```bash
    traceroute www.example.com
    ```

17. **ssh**: Secure Shell to connect to remote servers.

    ```bash
    ssh user@hostname
    ```

18. **wget**: Download files from the internet.

    ```bash
    wget https://www.example.com/file.zip
    ```

## System Administration

19. **sudo**: Execute commands with elevated privileges.

    ```bash
    sudo command
    
    or you can execute multiple commands with sudo like
    sudo sh -c 'cd /var/www/html/www-website-com && ./drush cr'
    
    or here in example I am taking a pull from bug-fix branch and merging into prod branch using one liner command with sudo
    
    sudo sh -c 'cd /var/www/html/www-website-com && git switch bug-fix && git pull origin bug-fix && git switch prod && git merge bug-fix'
    
    above command will execute commands in order like
    
    # changing the working directory
    - cd /var/www/html/www-website-com
    # Switching to bug-fix branch
    - git switch bug-fix
    # Taking a git pull from bug-fix
    - git pull origin bug-fix
    # Switching to branch prod
    - git switch prod
    # Merging bug-fix branch code into prod
    - git merge bug-fix
    ```

20. **ufw**: Uncomplicated Firewall for managing iptables.

    ```bash
    ufw allow 80
    ```

21. **apt, yum, pacman**: Package managers for installing software.

    ```bash
    apt install package
    ```

22. **systemctl**: Control the systemd system and service manager.

    ```bash
    systemctl start service
    ```

23. **crontab**: Schedule periodic tasks.

    ```bash
    crontab -e
    ```

24. **lscpu**:See teh no of cpu in linux system.

    ```bash
    lscpu
    ```

25. **timedatectl**:Set Date and Time Zone in Linux

    ```bash
    # List available time zones to find "Asia/Kolkata"
    timedatectl list-timezones | grep Asia/Kolkata

    # Set the time zone to "Asia/Kolkata"
    sudo timedatectl set-timezone Asia/Kolkata

    # Verify the changes
    timedatectl
    ```
    
These are fundamental Linux commands for everyday use, covering file operations, system information, compression, networking, and system administration. Explore and practice them to become proficient in Linux.

<br/><br/>

> # Amazon Linux 2 PHP 8.1 installation


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

<br/><br/>

> # Essential Git Commands


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

# if you want to delete multiple files then use "{file-a,file-b}"
java -jar ~/Downloads/bfg-1.14.0.jar .git --delete-files "{settings.php,settings.local.php}"

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

<br/><br/>

> # AWS CLI Commands


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

<br/><br/>

> # FFMPEG Commands


```bash
# WebM to MP4:
ffmpeg -i xss.webm -strict experimental video.mp4
ffmpeg -i xss.webm -movflags faststart -profile:v high -level 4.2 xss.mp4

# MP4 to Image:
ffmpeg -i video.mp4 -r 1/1 $filename%03d.jpg
```

<br/><br/>

> # OpenSSL Commands


```bash
# Encrypt: Use openssl to encrypt the file:
openssl aes-256-cbc -a -salt -in secrets.txt -out secrets.txt.enc

# Decrypt: Use openssl to decrypt the file:
openssl aes-256-cbc -d -a -in secrets.txt.enc -out secrets.txt.new

# Integrate Subresource Integrity Check
openssl dgst -sha384 -binary README.md | openssl base64 -A
```

<br/><br/>

> # Nginx Drupal settings


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

<br/><br/>

> # PHP FPM | INI config


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
disable_functions=exec,passthru,shell_exec,system,popen,phpinfo,shell_exec,curl_multi_exec,parse_ini_file
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

<br/><br/>

> # Useful bash scripts

```bash
#!/bin/bash

# Git Auto Pull Shell Script
# Fetch latest code from github if any commit has made in branch or script to pull the latest drupal code from master branch if any changes are there
# Version 1.0
# Author Neeraj Singh

# Change directory to the Drupal root directory
cd /var/html/www

# Save the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Set current branch name
BRANCH=master

# Check if there are any changes in the remote branch
git fetch origin $BRANCH
CHANGES=$(git rev-list HEAD..origin/$BRANCH --count)

# Only pull changes if there are any
if [ $CHANGES -gt 0 ]; then
    # Check out the branch you want to pull
    git checkout $BRANCH

    # Pull the latest changes from the remote branch
    git pull origin $BRANCH

    # Check if composer.json has changed
    if git diff --quiet composer.json; then
        echo "composer.json has not changed."
    else
        echo "composer.json has changed. Running 'composer install'..."
        composer install
    fi

    # Path to Drush executable
    DRUSH_EXECUTABLE="./vendor/bin/drush"

    # Check if Drush is installed in the vendor/bin directory
    if [ -x "$DRUSH_EXECUTABLE" ]; then
        echo "Drush is installed in vendor/bin directory. Running 'drush cr'..."
        "$DRUSH_EXECUTABLE" cr
        # Delete the watchdog table logs (optional)
        # "$DRUSH_EXECUTABLE" -y wd-del all
    else
        echo "Drush is not found in vendor/bin directory."
    fi

    # Check if any errors occurred during the pull
    if [ $? -ne 0 ]; then
        # If there were errors, revert back to the previous state
        git reset --hard HEAD
        # Switch back to the previous branch
        git checkout $CURRENT_BRANCH
        # Exit the script with an error code
        exit 1
    fi

    # If there were no errors, switch back to the previous branch
    git checkout $CURRENT_BRANCH

    # Exit the script with a success code
    exit 0
else
    # No changes in the remote branch, exit the script with a success code
    exit 0
fi
```

```bash
#!/bin/bash

# This is the script to export the sql backup to s3 bucket
# Database connection details

# -------------------------------------
# WARNING!! PUTTING A PASSWORD IN THE SHELL SCRIPT IS NOT RECOMMENDED
# use ENV vars instead
# -------------------------------------

# Seta cron like below to execute this everyday 11:30 PM
# chmod +x /path/to/daily-sql-backup.sh
# 30 23 * * * /path/to/daily-sql-backup.sh
# 30 23 * * * /path/to/daily-sql-backup.sh >> /path/to/logfile.log 2>&1

DB_USER="root"
DB_PASSWORD="root"
DB_NAME="hashkal"
HOST_NAME="localhost"
# S3 bucket and path
S3_BUCKET="s3-sync-source"
S3_PATH="prod/backup"
# Directory for temporary backup files
BACKUP_DIR="/root"
# MySQL dump filename
DUMP_FILENAME="sqldumpprod-$(date +%d%m%y).sql.gz"
# Check if the file already exists in S3
if aws s3 ls "s3://$S3_BUCKET/$S3_PATH/$DUMP_FILENAME"; then
    echo "File $DUMP_FILENAME already exists in S3. Skipping backup upload."
else
    # Export the MySQL database
    mysqldump --set-gtid-purged=OFF --column-statistics=0 --add-drop-table --no-tablespaces -u $DB_USER -p$DB_PASSWORD $DB_NAME -h $HOST_NAME | gzip > $BACKUP_DIR/$DUMP_FILENAME
    # Compress the SQL dump using gzip
    # gzip $BACKUP_DIR/$DUMP_FILENAME
    # Upload the compressed file to S3
    /usr/local/bin/aws s3 cp $BACKUP_DIR/$DUMP_FILENAME s3://$S3_BUCKET/$S3_PATH/
    # Delete the local gzip file
    rm $BACKUP_DIR/$DUMP_FILENAME
fi
```

```bash
#!/bin/bash

# This is the script to import the sql backup from s3 bucket
# e.g. db-name - sqldumpprod-251223.sql.gz refers 25 Dec, 2023

# Database connection details

# MySQL Database Credentials
DB_USER="root"
DB_PASSWORD="superpassword"
DB_NAME="dbname"
HOST_NAME="localhost"

# S3 bucket and path
S3_BUCKET="s3-sync-source"   
S3_PATH="prod/backup"

# Directory for temporary backup files
BACKUP_DIR="/root"

# aws bin file
AWS="/usr/local/bin/aws"

# Function to download the dump file from S3
download_from_s3() {
    local dump_filename="$SQLDUMP"
    local s3_url="s3://$S3_BUCKET/$S3_PATH/$dump_filename"
    
    # Check if the file already exists in S3
    if $AWS s3 ls "$s3_url"; then
        echo "Downloading file from S3..."
        $AWS s3 cp "$s3_url" "$BACKUP_DIR/$dump_filename"
        return 0  # Success
    else
        echo "File $dump_filename not found on S3 for the specified date."
        return 1  # Failure
    fi
}

# Prompt the user for a date in "ddmmyy" format
read -p "Backup date (e.g for 25 Dec, 2022 enter 251223)?: " DATE_RESTORE

# Check if the input is in the correct format
if ! [[ "$DATE_RESTORE" =~ ^[0-9]{6}$ ]]; then
    echo "Invalid date format. Please enter in ddmmyy format."
    exit 1
fi

# setting sql dump file name
SQLDUMP="sqldumpprod-$DATE_RESTORE.sql.gz"

# Download the dump file from S3
if download_from_s3 "$DATE_RESTORE"; then
    # Import MySQL dump
    echo "Importing MySQL dump..."
    zcat "$BACKUP_DIR/$SQLDUMP" | mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME -h $HOST_NAME
    echo "Import completed successfully."

    # Delete the local gzip file
    rm "$BACKUP_DIR/$SQLDUMP"
    echo "Backup removed from local server"

else
    echo "Download from S3 failed. Import process aborted."
    exit 1
fi

```

```bash
#!/bin/bash
  
# git-pull-drupal.sh
# To set this script as CRON job to run and check pull in every 5 minutes
# */5 * * * * /root/git-pull-drupal.sh >> /var/www/html/git-cron.log 2>&1

# NOTE: This git pull has a token based repository and has read 
# only access to pull the code without password
# To set token based authentication instead password for git pull
# git remote add origin https://<my-repo-access-token>@bitbucket.org/website-com/cms.git

# Change directory to the Drupal root directory
cd /var/www/html/www-website-com/public_html

# Save the current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Set teh branch name
BRANCH=production

# Check if there are any changes in the remote branch
git fetch origin $BRANCH
CHANGES=$(git rev-list HEAD..origin/$BRANCH --count)

# Only pull changes if there are any
if [ $CHANGES -gt 0 ]; then
  # Check out the branch you want to pull
  git checkout $BRANCH

  # Pull the latest changes from the remote branch
  git pull origin $BRANCH

  # Check if any errors occurred during the pull
  if [ $? -ne 0 ]; then
    # If there were errors, revert back to the previous state
    git reset --hard HEAD
    # Switch back to the previous branch
    git checkout $CURRENT_BRANCH
    # Exit the script with an error code
    exit 1
  fi

  # If there were no errors, switch back to the previous branch
  git checkout $CURRENT_BRANCH

  # Exit the script with a success code
  exit 0
else
  # No changes in the remote branch, exit the script with a success code
  exit 0
fi
```

```bash
#!/bin/bash

# Below script automates post-update tasks for a web application, ensuring that the codebase is updated, dependencies are installed, caches are rebuilt, and the website remains in a healthy state. If any issues arise during this process, the script attempts to revert changes to maintain the application's stability.

# Website to check for errors
WEBSITE="https://www.site.com"

# Project folder
PROJECT_FOLDER="/var/www/html/www-site-com"

# Path to drush executable
DRUSH_EXECUTABLE="$PROJECT_FOLDER/vendor/bin/drush"

# Name of the master branch
MASTER_BRANCH="master"

# Function to check if the drush command is available
drush_available() {
    [ -x "$DRUSH_EXECUTABLE" ]
}

# Move to the project folder
cd "$PROJECT_FOLDER"

# Check the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Switch to master branch if not already on master
if [ "$current_branch" != "$MASTER_BRANCH" ]; then
    echo "Switching to master branch..."
    git checkout "$MASTER_BRANCH"

    # Check if the branch switch was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to switch to master branch. Aborting."
        exit 1
    fi
fi

# Check for new commits
if [ "$(git rev-list HEAD...origin/$MASTER_BRANCH --count)" -eq 0 ]; then
    echo "No new commits in the $MASTER_BRANCH branch. Aborting."
    exit 1
fi

# Perform git pull
git pull

# Check if composer.json is modified
if git diff --name-only HEAD@{1} | grep -q "composer.json"; then
    echo "composer.json has changed. Running composer install..."
    composer install

    # Check if composer install was successful
    if [ $? -ne 0 ]; then
        echo "Error: Composer install failed. Reverting git pull."
        git reset --hard HEAD^
        exit 1
    fi
fi

# Check if drush command is available
if drush_available; then
    echo "Running drush cache rebuild..."
    $DRUSH_EXECUTABLE cr

    # Check if drush cache rebuild was successful
    if [ $? -ne 0 ]; then
        echo "Error: Drush cache rebuild failed. Reverting git pull."
        git reset --hard HEAD^
        exit 1
    fi
else
    echo "Error: Drush command not available. Aborting."
    exit 1
fi

# Check if the website is running properly
if [ $(curl -LI $WEBSITE -o /dev/null -w '%{http_code}\n' -s) == "200" ]; then
    echo "Website $WEBSITE is running properly after the git pull."
else
    echo "Error: Website $WEBSITE is not giving a 200 response. Reverting git pull."
    git reset --hard HEAD^

    # Run drush cache rebuild again
    $DRUSH_EXECUTABLE cr

    # Check if drush cache rebuild was successful after git pull revert
    if [ $? -ne 0 ]; then
        echo "Error: Drush cache rebuild failed even after git pull revert. Please investigate."
    else
        echo "Git pull reverted. Drush cache rebuild successful after git pull revert."
    fi

    exit 1
fi

```

<br/><br/>

> # CRON Jobs example

```bash
# [ Crontab Settings ]
# =========================

# SQL Backup every day at 11:30 PM
30 23 * * * /root/daily-sql-backup.sh >> /root/cronlogfile.log 2>&1

# hashi-corp Cron Settings @ Updated 27 July 2022

# hashi-corp code sync from s3 to server every 30 minutes -- Disabled for now
# 30 */2 * * * aws s3 sync s3://hashi-corp-sync-source/prod/www.website.com/ /var/www/html/www-website-com/ --exact-timestamps && chown -R www-data:www-data /var/www/html/www-website-com/


# hashi-corp daily code push from server to s3 @ 4 AM
0 4 * * * aws s3 sync /var/www/html/www-website-com/ s3://hashi-corp-sync-source/prod/www.website.com/ --exclude '*.gz' --exclude '.git/*' --exclude 'backup/*' --exclude 'twig/*'


# hashi-corp hotel lead import script for every 5 minutes
*/5 * * * * cd /var/www/html/www-website-com && /var/www/html/www-website-com/vendor/bin/drush isbl >> /var/www/html/www-website-com/isbl-cron.log 2>&1


# hashi-corp emailers images sync from s3 to server everyday @ 8 AM
# 0 20 * * * aws s3 sync s3://hashi-corp-sync-source/prod/www.website.com/web/img/email-images/ /var/www/html/www-website-com/web/img/email-images/ --exact-timestamps && chown -R www-data:www-data /var/www/html/www-website-com/web/img/email-images/


# hashi-corp emailers images sync from s3 to server on every midnight
0 0 * * * aws s3 sync s3://hashi-corp-sync-source/prod/content/email-images/ /var/www/html/www-website-com/web/img/email-images/ --exact-timestamps && chown -R www-data:www-data /var/www/html/www-website-com/web/img/email-images/ && systemctl restart varnish nginx

# Delete watch dog table entries
# */8 * * * * /var/www/html/www-website-com/vendor/bin/drush sql-query "DELETE FROM watchdog"

# Delete watch dog table entries
*/10 * * * * /var/www/html/www-website-com/vendor/bin/drush drush sql-query "DELETE FROM watchdog WHERE wid NOT IN (SELECT wid FROM (SELECT wid FROM watchdog ORDER BY timestamp DESC LIMIT 5000) AS temp);"
```

<br/><br/>

> # Using SSH Key for GitHub Authentication on macOS


## Overview

This guide explains how to set up and use SSH keys for authenticating with your GitHub account on macOS. SSH keys provide a secure and convenient way to authenticate and interact with GitHub repositories without entering your username and password for each interaction.

## Prerequisites

- **macOS Terminal:** Ensure you have access to the Terminal application on your macOS.

### Steps

#### 1. **Check for Existing SSH Keys:**

Before generating a new SSH key, check if you already have existing SSH keys:

```bash
ls -al ~/.ssh
```

Look for files named `id_rsa` (private key) and `id_rsa.pub` (public key). If they exist, you can skip the key generation step.

#### 2. **Generate a New SSH Key:**

If you don't have an existing SSH key, generate a new one:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Follow the prompts, and optionally, set a passphrase for added security.

#### 3. **Start SSH Agent:**

Start the SSH agent to manage your keys:

```bash
eval "$(ssh-agent -s)"
```

#### 4. **Add SSH Key to SSH Agent:**

Add your SSH private key to the SSH agent:

```bash
ssh-add -K ~/.ssh/id_rsa
```

#### 5. **Copy SSH Key to Clipboard:**

Copy the SSH key to your clipboard:

```bash
pbcopy < ~/.ssh/id_rsa.pub
```

#### 6. **Add SSH Key to GitHub:**

- Go to your GitHub account settings.
- Navigate to "SSH and GPG keys."
- Click on "New SSH key."
- Paste your SSH key into the "Key" field.
- Give it a descriptive title and save.

#### 7. **Test the Connection:**

Test your SSH connection to GitHub:

```bash
ssh -T git@github.com
```

You should see a message confirming your successful authentication.

### How to use?

1. **Check SSH Agent:**
   Ensure that your SSH agent is running and has your private key loaded. You can start the SSH agent and add your key using the following commands:

   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/your_private_key #id_rsa
   ```

   Replace `your_private_key` with the actual name of your private key.

2. **Verify SSH Key:**
   Make sure that the public key associated with your private key is added to your GitHub account. You can check and copy your public key using:

   ```bash
   cat ~/.ssh/your_private_key.pub #id_rsa.pub
   ```

   Add the public key to your GitHub account in the "SSH and GPG keys" settings.

3. **Check SSH Configuration:**
   Ensure that your SSH configuration is set up correctly. Open or create the `~/.ssh/config` file and make sure it includes the following:

   ```
   Host github.com
     HostName github.com
     User git
     IdentityFile ~/.ssh/id_rsa
   ```

   Replace `your_private_key` with the actual name of your private key.

4. **Update Git Remote URL:**
   If you are still having issues, you can try updating the remote URL for your Git repository. Change the remote URL to use the SSH format:

   ```bash
   git remote set-url origin git@github.com:your_username/your_repository.git
   ```

   Replace `your_username` and `your_repository` with your GitHub username and repository name.

5. **HTTPS Instead of SSH (Optional):**
   If you continue to face issues with SSH, you can temporarily switch to using HTTPS for cloning and pushing:

   ```bash
   git remote set-url origin https://github.com/your_username/your_repository.git
   ```

   This method uses your GitHub username and password for authentication.

6. **Check Repository Existence:**
   Ensure that the repository exists on GitHub and that you have the correct permissions to access it.

   **Working example**
 
    ```bash
    # Change directory to the web server's root directory
    cd /usr/local/var/www

    # Create a directory named 'github' and navigate into it
    mkdir github
    cd github

    # Initialize a new Git repository
    git init

    # Configure the Git user name
    git config user.name "email.last@company.com"

    # Add a README.md file to the staging area
    git add README.md

    # Append a line to the README.md file
    echo "# best-brand-website" >> README.md

    # Add the modified README.md file to the staging area
    git add README.md

    # Commit the changes with a commit message
    git commit -m "first commit"

    # Create and switch to a new branch named 'master'
    git branch master

    # Add a remote repository named 'origin' with the specified URL
    git remote add origin git@github.com:company/best-brand-website.git

    # Generate an SSH key pair with a specific email
    ssh-keygen -t rsa -b 4096 -C "email.last@company.com"

    # Start the SSH agent and set up the environment variables
    eval "$(ssh-agent -s)"

    # Copy the SSH public key to the clipboard
    pbcopy < /Users/scott/.ssh/id_rsa.pub

    # Manually paste the SSH key in the GitHub SSH Key settings

    # Display the content of the SSH public key file
    cat /Users/scott/.ssh/id_rsa.pub

    # Create or edit the SSH configuration file and add GitHub settings
    cat > ~/.ssh/config

    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa_mgh

    # Press Ctrl + D to exit the input mode and save the content.

    # Push the local 'master' branch to the remote 'origin' repository
    git push origin master
    ```

After following these steps, try cloning the repository again. If you're still facing issues, double-check each step to make sure everything is configured correctly. If the problem persists, consider checking GitHub's documentation or contacting their support for further assistance.
