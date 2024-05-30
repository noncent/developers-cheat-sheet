# Here you will find the daily use scripts

## Importing a gzip-compressed SQL file into a MySQL database

### Method 1: Using the Command Line

1. **Prepare the Database**:
   Ensure the target database exists. If not, create it using:
   ```bash
   mysql -u [username] -p -e "CREATE DATABASE [database_name];"
   ```

2. **Import the Gzip File**:
   You can use the `gunzip` command to decompress the file and pipe the output directly to `mysql`:
   ```bash
   gunzip < /path/to/yourfile.sql.gz | mysql -u [username] -p [database_name]
   ```

### Method 2: Using zcat (or gzcat on macOS)

If you prefer not to extract the file first, you can use `zcat` (or `gzcat` on macOS) to read the compressed file and pipe it directly to `mysql`:
```bash
zcat /path/to/yourfile.sql.gz | mysql -u [username] -p [database_name]
```
or
```bash
zcat < /path/to/yourfile.sql.gz | mysql -u [username] -p [database_name]
```

### Method 3: Using MySQL Client with Decompression

Some systems support decompression directly within the MySQL command by specifying the file with redirection:
```bash
mysql -u [username] -p [database_name] < <(gunzip -c /path/to/yourfile.sql.gz)
```

## MySQL dump as gzip format

```bash
# Export the MySQL database
mysqldump --set-gtid-purged=OFF --column-statistics=0 --add-drop-table --no-tablespaces -u db-user -p db-name -h localhost | gzip > /usr/db/sqldump-$(date +%d%m%y).sql.gz
```

## MySQL dump excluding some tables as gzip format

```bash
#!/bin/bash
# This is the script to export teh sql backup to s3 bucket
# Database connection details
# daily-sql-backup.sh
DB_USER="DB-USER"
DB_PASSWORD="DB-PWD"
DB_NAME="DB-NAME"
HOST_NAME="DB-HOST"
# S3 bucket and path
S3_BUCKET="sync-source"
S3_PATH="prod/backup"
# Directory for temporary backup files
BACKUP_DIR="/root"
# MySQL dump filename
DUMP_FILENAME="sqldumpprodnu$1-$(date +%d%m%y).sql.gz"

EXCLUDED_TABLES=(
    booking_enquiries
    gha_booking_lead
    gha_user_tracking
    ghasso_detail
    history
    hotel_enquiries
    hotel_guests_child_enquiries
    hotel_guests_enquiries
    node__webform
    node_revision__webform
    sabre_booking_lead
    users_data
    users_field_data
    webform
    webform_access_group_admin
    webform_access_group_entity
    webform_access_group_user
    webform_submission
    webform_submission_data
)

IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"; do
    :
    IGNORED_TABLES_STRING+=" --ignore-table=${DB_NAME}.${TABLE}"
done

# Check if the file already exists in S3
if aws s3 ls "s3://$S3_BUCKET/$S3_PATH/$DUMP_FILENAME"; then
    echo "File $DUMP_FILENAME already exists in S3. Skipping backup upload."
else
    # Export the MySQL database
    mysqldump --set-gtid-purged=OFF --column-statistics=0 --add-drop-table --no-tablespaces -u $DB_USER -p$DB_PASSWORD $DB_NAME -h $HOST_NAME ${IGNORED_TABLES_STRING} | gzip >$BACKUP_DIR/$DUMP_FILENAME

    # Upload the compressed file to S3
    /usr/local/bin/aws s3 cp $BACKUP_DIR/$DUMP_FILENAME s3://$S3_BUCKET/$S3_PATH/

    # Delete the local gzip file
    rm $BACKUP_DIR/$DUMP_FILENAME

    echo "File $DUMP_FILENAME deleted successfully."
fi
```

## How to know if files contains a string e.g. "www" searching folders and subfolder

The command `grep -lr "www" .` is used to search for files within the current directory (and its subdirectories) that contain the string "www". Here's a breakdown of what each part of the command does:

- `grep`: The command-line utility used for searching plain-text data for lines that match a regular expression.
- `-l`: This option stands for "files with matches". It tells `grep` to only print the names of files that contain the matching text, rather than the matching lines themselves.
- `-r`: This option stands for "recursive". It instructs `grep` to search recursively through all files and directories under the specified directory.
- `"www"`: The string (or pattern) that `grep` is searching for within the files.
- `.`: The current directory. This tells `grep` to start its search from the current directory.

### Summary

The command `grep -lr "www" .` will:

1. Recursively search through all files in the current directory and its subdirectories.
2. Look for occurrences of the string "www" in those files.
3. Print the names of the files that contain the string "www".

### Example Output

If you run this command in a directory structure like the following:

```
.
├── file1.txt
├── file2.txt
└── subdir
    ├── file3.txt
    └── file4.txt
```

And suppose `file1.txt` and `file4.txt` contain the string "www", the output will be:

```
./file1.txt
./subdir/file4.txt
```

This output indicates that `file1.txt` and `file4.txt` both contain the string "www".
