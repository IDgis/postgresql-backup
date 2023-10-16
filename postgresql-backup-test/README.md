# postgresql-backup-test

# Deploy
- docker compose up -d

# Manually run backup
- docker exec postgresql-backup-test-backup-1 bash -c "/opt/backup.sh > /opt/fifo 2>&1"

# Check

## Container log
- docker logs postgresql-backup-test-backup-1

## Resulting sql
- docker exec postgresql-backup-test-backup-1 pg_restore -f - /backup/db_5432_db_0.sql
- docker exec postgresql-backup-test-backup-1 pg_restore -f - /backup/db_5432_db_1.sql

## Duplicity files on the sftp server
- docker exec postgresql-backup-test-sftp-1 find /home/sftp_user
