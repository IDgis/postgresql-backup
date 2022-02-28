#!/bin/bash

set -eu

all_environment_values() {
    ( set -o posix ; set ) \
        | grep $1 \
        | cut -d = -f 2
}

# Store database connection parameters
rm ~/.pgpass
for db in $(all_environment_values DATABASE); do
    echo $db >> ~/.pgpass
done

chmod 0600 ~/.pgpass

# Store ssh key
mkdir -p /root/.ssh
ssh-keyscan -p $SFTP_PORT $SFTP_HOST > ~/.ssh/known_hosts

# Get back-up using duplicity
duplicity restore \
    --no-encryption \
    --force \
    sftp://$SFTP_USER:$SFTP_PASSWORD@$SFTP_HOST:$SFTP_PORT/$BACKUP_NAME \
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

echo Back-up restored: $(date)
