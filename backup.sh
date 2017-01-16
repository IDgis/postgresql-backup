#!/bin/bash

if [ -f /var/run/backup.pid ]; then
	if [ -d /proc/$(cat /var/run/backup.pid) ]; then
		echo backup is already running... $(date)
		exit 0
	else
		echo obsolete pid file found: /var/run/backup.pid
	fi
fi

echo $$ > /var/run/backup.pid

echo Performing remote backup: $(date)

# loading settings
. /etc/backup

rm -fr /backup
mkdir /backup
cd /backup

# dump databases
while read db; do
	IFS=: db_parts=( $db )
	
	echo Dumping database ${db_parts[0]}:${db_parts[1]}/${db_parts[2]}...
	
	pg_dump \
		-v \
		-h ${db_parts[0]} \
		-p  ${db_parts[1]} \
		-F c \
		-f ${db_parts[0]}_${db_parts[1]}_${db_parts[2]}.sql \
		-U ${db_parts[3]} ${db_parts[2]}
done < ~/.pgpass

# perform an incremental backup using duplicity:
echo "Performing incremental backup..."
duplicity incremental \
	--allow-source-mismatch \
	--no-encryption \
	--full-if-older-than=7D \
	/backup \
	"$BACKUP_URL"

echo "Removing old backups..."
duplicity remove-older-than \
	--allow-source-mismatch \
	14D \
	--force \
	"$BACKUP_URL"

# show backup files
echo Backup files:
du -h /backup/*

# cleanup
rm /var/run/backup.pid 

echo Backup finished: $(date)