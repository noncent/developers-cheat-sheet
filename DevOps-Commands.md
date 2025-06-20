
# Command Reference

Below are categorized commands for MySQL database operations, file transfers, and backups. **Note:** These commands are for reference/documentation purposes only. They do not delete any data. Each command is commented to describe its purpose.

---

## MySQL Commands

```bash
# Take a mysqldump for selected tables and compress the output
mysqldump --defaults-extra-file=./your-credentials.cnf your_database \
  --set-gtid-purged=OFF --column-statistics=0 --add-drop-table --no-tablespaces \
  table1 table2 table3 \
  | gzip > selected_tables_dump_$(date +%y%m%d).sql.gz

# Connect to MySQL using a credentials file
mysql --defaults-extra-file=./your-credentials.cnf

# Import a gzipped SQL dump into MySQL
gunzip -c your_dump.sql.gz | mysql --defaults-extra-file=./your-credentials.cnf your_database

# Take a mysqldump excluding specific tables and compress the output
mysqldump --defaults-extra-file=./your-credentials.cnf your_database \
  --set-gtid-purged=OFF --column-statistics=0 --add-drop-table --no-tablespaces \
  --ignore-table=your_database.table1 \
  --ignore-table=your_database.table2 \
  | gzip > excluded_tables_dump_$(date +%y%m%d).sql.gz

# Replace collation in a gzipped SQL backup and import into MySQL
zcat /path/to/backup.sql.gz | sed 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' | mysql -u root -p your_database

# Pipe a SQL file over SSH and import into a remote Azure MySQL database
cat /path/to/backup.sql | ssh user@remote_host "mysql -h yourserver.mysql.database.azure.com -P 3306 -u youruser -p your_database"
```

---

## Linux File Operations

```bash
# Create a tar.gz archive of the current directory, excluding certain files/folders
tar --exclude='*.zip' --exclude='*.tar' --exclude='.git' -czf archive.$(date +%y%m%d).tar.gz .

# Extract a tar.gz archive
tar -xzf archive.$(date +%y%m%d).tar.gz
```

---

## File Transfer Commands

```bash
# Securely copy a file from a remote server
scp user@remote_host:/path/to/file .

# Securely copy a backup zip file to a remote server
scp /path/to/backup.zip user@remote_host:/path/to/destination/
```

---

## AWS S3 Commands

```bash
# Upload a backup file to AWS S3
aws s3 cp ./archive.tar.gz s3://your-bucket/backups/

# Generate a pre-signed S3 URL for temporary access to a backup file
aws s3 presign s3://your-bucket/backups/archive.tar.gz --expires-in 1800
```

---

## Download Commands

```bash
# Download a file using curl with a custom Host header
curl -L -H "Host: yourdomain.com" -o output.sql.gz http://your.server.ip/output.sql.gz
```

