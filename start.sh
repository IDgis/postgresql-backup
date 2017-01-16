#!/bin/bash

# produce all values of environment
# variables with a name starting with $1
all_environment_values() {
	( set -o posix ; set ) \
		| grep $1 \
		| cut -d = -f 2
}

echo Generating config...

# store database connection parameters for pg_dump
for db in $(all_environment_values DATABASE); do
	echo $db >> ~/.pgpass
done

chmod 0600 ~/.pgpass

# store ssh key
mkdir -p /root/.ssh
ssh-keyscan -p $SFTP_PORT $SFTP_HOST > ~/.ssh/known_hosts

# store backup url
echo BACKUP_URL=sftp://$SFTP_USER:$SFTP_PASSWORD@$SFTP_HOST:$SFTP_PORT/$BACKUP_NAME > /etc/backup

mkfifo /opt/fifo
# tigger 'tail -f' to open fifo
echo Logging started... > /opt/fifo &

echo "00 5 * * * root /opt/backup.sh > /opt/fifo 2>&1" > /etc/crontab

echo Starting cron...

cron
tail -f /opt/fifo
