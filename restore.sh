#!/bin/bash

set -eu

echo Restoring remote backup: $(date)

# loading settings
. /etc/backup

# Get back-up using duplicity
duplicity restore \
    --no-encryption \
    --force \
    "$BACKUP_URL" \
    /backup

# Restore databases
while read db; do
    IFS=: db_parts=( $db )

    echo Restoring database ${db_parts[0]}_${db_parts[1]}_${db_parts[2]}.sql

    # Restore schemas
    /usr/lib/postgresql/${db_parts[5]}/bin/pg_restore \
        -d ${db_parts[2]} \
        /backup/${db_parts[0]}_${db_parts[1]}_${db_parts[2]}.sql \
        -F c \
        -c \
        -h ${db_parts[0]} \
        -p ${db_parts[1]} \
        -U "${db_parts[3]}" \
        -s

    # Restore data
    /usr/lib/postgresql/${db_parts[5]}/bin/pg_restore \
        -d ${db_parts[2]} \
        /backup/${db_parts[0]}_${db_parts[1]}_${db_parts[2]}.sql \
        -F c \
        -c \
        -h ${db_parts[0]} \
        -p ${db_parts[1]} \
        -U "${db_parts[3]}"
done < ~/.pgpass

echo Backup restored: $(date)
