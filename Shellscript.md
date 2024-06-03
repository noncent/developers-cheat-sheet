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

## loop git pull for multiple projects

```bash
#!/bin/bash

# Define the root folder for Drupal installations
ROOT_FOLDER="/var/www/html"

# Declare an associative array to hold site names and their corresponding Git branches
declare -A sites

# Populate the array with site names and their corresponding branches
sites["beta"]="master"
sites["uat/uat-site"]="uat"
sites["staging"]="staging"

# Loop through each site and perform Git operations
for site in "${!sites[@]}"; do
    echo
    echo "Running script for $site ..."
    echo 

    # Change to the site's directory
    cd "$ROOT_FOLDER/$site" || { echo "Failed to change directory to $ROOT_FOLDER/$site"; continue; }

    # Save the current Git branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Get the branch to pull from the associative array
    TARGET_BRANCH=${sites[$site]}

    # Fetch the latest changes from the remote repository for the target branch
    git fetch origin $TARGET_BRANCH

    # Count the number of changes between the local and remote branch
    CHANGES=$(git rev-list HEAD..origin/$TARGET_BRANCH --count)

    # If there are changes, pull the latest updates
    if [ "$CHANGES" -gt 0 ]; then
        # Check out the target branch
        git checkout $TARGET_BRANCH

        # Pull the latest changes from the remote branch
        git pull origin $TARGET_BRANCH

        # Check if the pull operation was successful
        if [ $? -ne 0 ]; then
            # If there were errors, reset the branch to the last known good state
            git reset --hard HEAD

            # Switch back to the original branch
            git checkout $CURRENT_BRANCH

            # Log the error
            echo "Error: Failed to pull changes for $site on branch $TARGET_BRANCH. Reverted to $CURRENT_BRANCH."
            # Continue to the next site without exiting the script
            continue
        fi

        # If the pull was successful, switch back to the original branch
        git checkout $CURRENT_BRANCH

        # Log the success
        echo "Successfully updated $site from branch $TARGET_BRANCH and reverted to $CURRENT_BRANCH."
    else
        # Log that there were no changes
        echo "No changes for $site on branch $TARGET_BRANCH."
    fi
done

# Set CRON to run the script in every 10 minutes on server
# Git auto pull code for staging
# */10 * * * * /roo/git_update_sites.sh >> /var/log/git-cron-$(date +\%Y\%m\%d).log 2>&1
```
