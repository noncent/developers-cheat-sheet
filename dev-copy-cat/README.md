# A Cheatsheet, Everyday commands for developers

### Drupal CMS
---

```html
 <!--Drupal files and folders permissions -->
/default on 755
/default/files including all subfolders and files on 744 (or 755)
/default/themes including all subfolders and files on 755
/default/modules including all subfolders and files on 755
/default/settings.php and /default/default.settings.php on 444

<!-- Go to base project folder -->
cd /opt/www-site-com

<!-- Change drupal folder permissions -->
chown -R nginx: drupal && chmod -R 777 drupal

<!-- Go inside drupal -->
cd drupal

<!-- Run composer -->
composer require 'drupal/key:^1.16' 'drupal/menu_item_extras:^2.19' 'drupal/paragraphs:^1.15' 'drupal/queue_ui:^3.1' 'drupal/real_aes:^2.5' 'drupal/s3fs:^3.1' 'drupal/services:^4.0@beta' 'drupal/smtp:^1.2' --with-all-dependencies

<!-- Create drush symlink if not exists -->
ln  -s vendor/bin/drush drush

<!-- Run update and cache clear -->
./drush updatedb && ./drush cr

<!-- Go back to project folder -->
cd ../

<!-- Revert permissions -->
chown -R www-data: drupal && chmod -R 755 drupal && chmod -R 444 drupal/sites/default/settings.php

<!-- Revert permissions if inside drupal -->
chown -R www-data: $(pwd) && chmod -R 755 $(pwd) && chmod -R 444 $(pwd)/sites/default/settings.php
```

## MySQL Commands
---

```html
<!-- Access monitor: -->
mysql -u [username] -p; (will prompt for password)

<!-- Show all databases: -->
show databases;

<!-- Access database: -->
mysql -u [username] -p [database] (will prompt for password)

<!-- Create new database: -->
create database [database];

<!-- Select database: -->
use [database];

<!-- Determine what database is in use: -->
select database();

<!-- Show all tables: -->
show tables;

<!-- Show table structure: -->
describe [table];

<!-- List all indexes on a table: -->
show index from [table];

<!-- Create new table with columns: -->
CREATE TABLE [table] ([column] VARCHAR(120), [another-column] DATETIME);

<!-- Adding a column: -->
ALTER TABLE [table] ADD COLUMN [column] VARCHAR(120);

<!-- Adding a column with an unique, auto-incrementing ID: -->
ALTER TABLE [table] ADD COLUMN [column] int NOT NULL AUTO_INCREMENT PRIMARY KEY;

<!-- Inserting a record: -->
INSERT INTO [table] ([column], [column]) VALUES ('[value]', '[value]');

<!-- MySQL function for datetime input: -->
NOW()

<!-- Selecting records: -->
SELECT * FROM [table];

<!-- Explain records: -->
EXPLAIN SELECT * FROM [table];

<!-- Selecting parts of records: -->
SELECT [column], [another-column] FROM [table];

<!-- Counting records: -->
SELECT COUNT([column]) FROM [table];

<!-- Counting and selecting grouped records: -->
SELECT *, (SELECT COUNT([column]) FROM [table]) AS count FROM [table] GROUP BY [column];

<!-- Selecting specific records: (Selectors: <, >, !=; combine multiple selectors with AND, OR) -->
SELECT * FROM [table] WHERE [column] = [value];

<!-- Select records containing [value]: -->
SELECT * FROM [table] WHERE [column] LIKE '%[value]%';

<!-- Select records starting with [value]: -->
SELECT * FROM [table] WHERE [column] LIKE '[value]%';

<!-- Select records starting with val and ending with ue: -->
SELECT * FROM [table] WHERE [column] LIKE '[val_ue]';

<!-- Select a range: -->
SELECT * FROM [table] WHERE [column] BETWEEN [value1] and [value2];

<!-- Select with custom order and only limit:  (Order: DESC, ASC) -->
SELECT * FROM [table] WHERE [column] ORDER BY [column] ASC LIMIT [value];

<!-- Updating records: -->
UPDATE [table] SET [column] = '[updated-value]' WHERE [column] = [value];

<!-- Deleting records: -->
DELETE FROM [table] WHERE [column] = [value];

<!-- Delete all records from a table (without dropping the table itself): -->
<!-- (This also resets the incrementing counter for auto generated columns like an id column.) -->
DELETE FROM [table];

<!-- Delete all records in a table: -->
truncate table [table];

<!-- Removing table columns: -->
ALTER TABLE [table] DROP COLUMN [column];

<!-- Deleting tables: -->
DROP TABLE [table];

<!-- Deleting databases: -->
DROP DATABASE [database];

<!-- Custom column output names: -->
SELECT [column] AS [custom-column] FROM [table];

<!-- Export a database dump (more info here): -->
<!-- Use --lock-tables=false option for locked tables (more info here). -->
mysqldump -u [username] -p [database] > db_backup.sql

<!-- Import a database dump (more info here): -->
mysql -u [username] -p -h localhost [database] < db_backup.sql

<!-- Logout: -->
exit;

<!-- Database export as GZip -->
mysqldump -u root -p localhost database_name | gzip > db_backup.sql.gz
mysqldump -u root -p -h localhost database_name | gzip > db_backup.sql.gz

<!-- mysqldump: Error 2020: Got packet bigger than 'max_allowed_packet'
bytes when dumping table `ib_mailbox_backup` at row: 3369 -->
mysqldump --max_allowed_packet=512M -u root -p -h localhost database_name | gzip > db_backup.sql.gz

<!-- $(date +'%d%m%Y') means current date in dmY format e.g. for 30 Dec 2022, print 30122022 -->

<!-- mysqldump throws: Unknown table 'COLUMN_STATISTICS' in information_schema (1109) -->

mysqldump --column-statistics=0 -h localhost -u root -p database_name | gzip -c > ./db_dumps/sql-$(date +'%d%m%Y').gz
mysqldump --column-statistics=0 -h localhost -u root -p database_name | gzip -c > ./db_dumps/$(date +'%d%m%Y').gz
mysqldump -u root -p database_name -h host | gzip > dbsql$(date +%d%m%y).sql.gz

<!-- Database import from GZip -->
zcat db_backup.sql.gz | mysql -u 'root' -p localhost database_name
gunzip < db_backup.sql.gz | mysql -u root -p database_name
zcat < db_backup.sql.gz | mysql -u root -p localhost database_name
zcat ./db_backup.sql.gz | mysql -u root -p database_name -h hostname


<!-- Import MySQL file to database: -->
mysql -u <user-name> -p < </full/path/database_import.sql>

<!-- Export MySQL file to database: -->
mysql -u <user-name> -p database > </full/path/database_export.sql>

<!-- Show all database sizes: -->
SELECT table_schema "<MY-DATABASE-NAME>", sum( data_length + index_length ) / 1024 / 1024 "Data Base Size in MB" FROM information_schema.TABLES GROUP BY table_schema;

<!-- Show all tables sizes for database: -->
SELECT table_name AS `Table`, round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` FROM information_schema.TABLES WHERE table_schema = "<MY-DATABASE-NAME>";
```

## GZip Commands
---

```html
<!-- Compress file/s and delete the original -->
gzip file.txt
gzip file1.txt file2.txt file3.txt
gzip *.txt

<!-- Compress a single file and keep the original -->
gzip -c file.txt > file.txt.gz
gzip -k file.txt > file.txt.gz

<!-- Compress all files recursively -->
gzip -r *

<!-- Decompress a gzip compressed file -->
gzip -d file.txt.gz
gunzip file.txt.gz

<!-- List of content file.txt, notes.txt, etc. -->
zcat test.txt.gz

<!-- Find / search in contents , will show example.pdf, etc. -->
zgrep exa test.txt.gz

```

## TAR Commands
---

```html

<!-- Create tar archive files & folders -->
tar -cvzf code.tar.gz ./code

<!-- Extract tar archive files in a folder -->
mkdir sample && tar -xf sample.tar.gz -C ./sample

<!-- List Content of tar contents -->
tar -tvf sample.tar.gz

<!-- Extract a single file from tar contents -->
tar -xvf sample.tar home.html
tar -zxvf sample.tar.gz home.html
tar -xvf sample.tar "file1" "file2" "..."
tar -xvf sample.tar --wildcards '*.php'

<!-- Append a file or folder in tar -->
tar -rvf sample.tar robots.txt

<!-- Check the Size of the tar File -->
tar -czf - sample.tar | wc -c

<!-- Exclude files and directories when creating tar file -->
tar --exclude='robots.txt' -zcvf backup.tar.gz /home/source
tar --exclude='*.txt' -zcvf backup.tar.gz /home/source

<!-- Remove file and directory from tar archive -->
tar --delete -f backup.tar.gz sample.txt
tar --delete -f backup.tar.gz '/home/source/uploads'
```


## Linux
---

```html

<!-- Top 50 Linux Commands You Must Know as a Regular User -->

<!-- ls - The most frequently used command in Linux to list directories -->
ls -la, ls -lart

<!-- pwd - Print working directory command in Linux -->
cd - Linux command to navigate through directories
cd folder
cd ../folder

<!-- mkdir - Command used to create directories in Linux -->
mkdir fruits

<!-- will create nested folders like fruits > red > apple -->
mkdir -p fruits/red/apple

<!-- mv - Move or rename files in Linux -->
mv sitemap.xml sitemap-backup.xml

<!-- will rename source folder as _source -->
mv source _source

<!-- cp - Similar usage as mv but for copying files in Linux -->
cp /backup/settings.php .
cp /backup/settings.php ./settings.php

<!-- rm - Delete files or directories -->
rm -rf unused newfolder test backup

<!-- touch - Create blank/empty files -->
touch README.txt

<!-- ln - Create symbolic links (shortcuts) to other files -->
ln -s ./vendor/bin/drush drush

<!-- cat - Display file contents on the terminal -->
<!-- clear - Clear the terminal display -->
<!-- echo - Print any text that follows the command -->

<!-- less - Linux command to display paged outputs in the terminal -->
less long-logs.log

<!-- man - Access manual pages for all Linux commands -->
<!-- uname - Linux command to get basic information about the OS -->
<!-- whoami - Get the active username -->
<!-- tar - Command to extract and compress files in Linux -->
<!-- Compress -->
tar -cvf <archive name> <files seperated by space>

<!-- Extract -->
tar -xvf <archive name>
zip <archive name> <file names separated by space>
unzip <archive name>

<!-- grep - Search for a string within an output -->
<!-- <Any command with output> | grep "<string to find>" -->
history | grep ssh

<!-- find command to find the filles -->
<!-- find the files and folders name contains backup -->
find .  -name "*backup*"

<!-- find the files contains DS_Store and then delete them -->
find . -type f -name ".DS_Store"  -delete

<!-- head - Return the specified number of lines from the top -->
<!-- tail - Return the specified number of lines from the bottom -->
<!-- diff - Find the difference between two files -->
diff <file 1> <file 2>

<!-- cmp - Allows you to check if two files are identical -->
<!-- comm - Combines the functionality of diff and cmp -->
<!-- sort - Linux command to sort the content of a file while outputting -->
<!-- export - Export environment variables in Linux -->
<!-- zip - Zip files in Linux -->
<!-- unzip - Unzip files in Linux -->
<!-- ssh - Secure Shell command in Linux -->
ssh username@hostname
<!-- SSH using pem file -->
ssh -i /source/secrets/key.pem user@34.12.12.12

<!-- service - Linux command to start and stop services -->
<!-- ps - Display active processes -->
<!-- kill and killall - Kill active processes by process ID or name -->
ps
kill <process ID>
killall <process name>

<!-- df - DISK FREE | Display disk filesystem information -->
<!-- mount - Mount file systems in Linux -->
<!-- chmod - Command to change file permissions or make them as executable -->
chmod +x loop.sh
<!-- setting recursive folder permission 655 -->
chmod -R 655 web-folder

<!-- chown - CHANGE OWNER: Command for granting ownership of files or folders -->
chown www-data: folder
chown -R www-data: folders

<!-- ifconfig - Display network interfaces and IP addresses -->
<!-- traceroute - Trace all the network hops to reach the destination -->
<!-- wget - Direct download files from the internet -->
<!-- ufw - Firewall command -->
iptables - Base firewall for all other firewall utilities to interface with
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
ufw allow 80

<!-- apt, pacman, yum, rpm - Package managers depending on the distro -->
<!-- Debian and Debian-based distros - apt install <package name> -->
<!-- Arch and Arch-based distros - pacman -S <package name> -->
<!-- Red Hat and Red Hat-based distros - yum install <package name> -->
<!-- Fedora and CentOS - yum install <package> -->
<!-- sudo - Command to escalate privileges in Linux -->
<!-- cal - View a command-line calendar -->
<!-- alias - Create custom shortcuts for your regularly used commands -->
alias lsl="ls -l"
OR
alias rmd="rm -r"

<!-- dd - Majorly used for creating bootable USB sticks -->
<!-- whereis - Locate the binary, source, and manual pages for a command -->
<!-- whatis - Find what a command is used for -->
<!-- top - View active processes live with their system usage -->
<!-- useradd and usermod - Add new user or change existing users data -->
<!-- passwd - Create or update passwords for existing users -->
```


## Amazon Linux 2 PHP 8.1 installation
---
```html
<!-- Find all installed PHP versions in repo -->
yum list installed | grep php
amazon-linux-extras | grep php

<!-- Remove all installed PHP versions from repo -->
yum remove php*

<!-- Install packages from epel or remi -->
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

<!-- Is used to download and make usable all the metadata for the currently enabled yum repos. -->
yum makecache

<!-- Install utility tools -->
yum -y install yum-utils

<!-- Disable the current active version from repo, other wise when you will run yum install php
it will always install php 7.4 version -->
amazon-linux-extras disable php7.4

<!-- Post disabling the PHP 7.4 enable the PHP 8.1 to install -->
yum-config-manager --enable remi-php81
amazon-linux-extras enable php8.1

<!-- Clean the yum cache -->
yum clean metadata

<!-- Now it will install PHP 8.1 version -->
yum install php

<!-- Check installed PHP version -->
php -v

<!-- Install PHP PEAR -->
yum install php-pear

<!-- Install PHP dev Utilities -->
yum install php-devel

<!-- Install image magic with PECL -->
pecl install imagick

<!-- Install other essential PHP extensions -->
yum install php-{pear,cgi,pdo,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imagick,mcrypt:}

<!-- Restart PHP FPM service -->
service php-fpm restart

<!-- Restart PHP service -->
systemctl php restart

<!-- Check if PHP and FPM services are running -->
ps aux | grep php

<!-- In case you want to install New relic for monitoring -->
newrelic-install

<!-- Restart PHP FPM service -->
systemctl restart php-fpm.service

<!-- Check for which version of PHP mcrypt installed -->
yum list installed | grep php | grep mcrypt

<!-- Update mcrypt for newer PHP version in cse already installed -->
yum update php-mcrypt

<!-- Install PHP extensions -->
yum install -y php-mbstring mcrypt

<!-- To see the FPM config e.g. www.conf -->
cd /etc/php-fpm.d
vi www.conf

<!-- Reload Nginx Reverse Proxy -->
service nginx reload

<!-- Restart Apache service in case not Nginx -->
service httpd reload

<!-- Check if Nginx or Apache configs has any error/syntax error -->
httpd -t
nginx -t

<!-- Reload Nginx Reverse Proxy -->
systemctl reload nginx.service

<!-- Check if PHP is running -->
systemctl | grep php

<!-- How much disk is free in human readable format -->
df -h

<!-- Check Disk Usages -->
du -sh

<!-- If you want to update all the installed linux packages -->
yum check-update

<!-- Check status of the services -->
systemctl status php-fpm.service
systemctl status nginx.service

<!-- The locate command finds files in Linux using the file name. -->
locate beauty-and-beast

<!-- See list of files visit https://man7.org/linux/man-pages/man1/ls.1.html-->
ls -lhrt

tail -f  /opt/www-site-com/log/error.log

<!--
    Copy all images from one step back to current images folder

    -r To copy a directory along with its sub dirctories.
    -p Preserves attribute of a file.
    -f Forcefully
 -->
cp -rpf ../public_html/*.jpg ./images

<!--  Delete folder name backups and all files ends with .gz -->
rm -rf backups *.tar.gz
```
