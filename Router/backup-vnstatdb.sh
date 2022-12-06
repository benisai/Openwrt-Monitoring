#!/bin/bash
DATE=$(date +%m-%d-%Y)
BACKUP_DIR="/etc/backup"
 
# backup the vnstat db and add a timestamp to the file
cp  /var/lib/vnstat/vnstat.db $BACKUP_DIR/vnstat.db-$DATE.bkp

# Delete files older than 5 days #
find $BACKUP_DIR/*.bkp -mtime +5 -exec rm {} \;




