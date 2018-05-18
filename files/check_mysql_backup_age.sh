#!/bin/bash

# um via nagios zu checken, ob auch wirklich Datenbank-Backups
# unter /var/backups/mysql/nfs/single gemacht werden
# (das passiert z.B. dann, wenn man die cronjobs für das Backup
# auskommentiert wenn das NFS-Volume über Nacht ungemounted ist)
# written by spfab, RT#597203


SINGLEBACKUPS='/var/backups/mysql/nfs/single'
OK_STATE=0
CRITICAL_STATE=2

if [ "$1" ]; then

	CRIT=$1

	LATESTFILE=$(ls -1rth $SINGLEBACKUPS | tail -n 1 )
	LATESTFILE="$SINGLEBACKUPS/$LATESTFILE"

	TIMESTAMP=$(/usr/bin/stat --printf=%Y $LATESTFILE)
	NOW=$(date +%s)
	DIFF=$(($NOW-$TIMESTAMP))

	if [ "$DIFF" -gt "$CRIT" ]; then
		echo "mysqlbackup is missing: latest file $LATESTFILE is older than $CRIT sec!"
		exit $CRITICAL_STATE
	else
		echo "mysqlbackup is OK: latest file $LATESTFILE is $DIFF sec old"
		exit $OK_STATE
	fi

else
	echo "Usage: $0 critical-age (in seconds)"
fi

