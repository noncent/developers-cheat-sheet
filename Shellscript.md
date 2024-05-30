# Here you will find the daily use scripts

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
