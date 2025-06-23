# postgresql-backup-test

# Deploy
- docker compose up -d

The backup is scheduled on every hour. This can be configured differently by
changing the SCHEDULE variable, e.g. to perform a backup every minute:
- SCHEDULE="* * * * *" docker compose up -d

# Manually run backup
- docker compose exec backup su - root -s /bin/bash -c "setsid /opt/backup.sh > /opt/fifo 2>&1 < /dev/null"

# Check

## Container log
- docker compose logs backup

## Resulting sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_0.sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_1.sql

## Duplicity files on the sftp server
- docker compose exec sftp find /home/sftp_user

# Restore
- docker compose exec backup bash -c "rm /backup/*"
- docker compose exec backup /opt/restore.sh

# Check

## Backup files
- docker compose exec backup find /backup

## Resulting sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_0.sql
- docker compose exec backup pg_restore -f - /backup/db_5432_db_1.sql
