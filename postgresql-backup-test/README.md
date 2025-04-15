# postgresql-backup-test

# Deploy
- docker compose up -d

# Manually run backup
- docker compose exec backup bash -c "/opt/backup.sh > /opt/fifo 2>&1"

# Check

## Container log
- docker compose logs backup

## Resulting sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_0.sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_1.sql

## Duplicity files on the sftp server
- docker compose exec sftp find /home/sftp_user
