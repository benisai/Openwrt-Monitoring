#!/bin/bash
DATE=$(date +%m-%d-%Y)
BACKUP_DIR="/etc/backup"
 
# backup the vnstat db and add a timestamp to the file
cp  /var/lib/vnstat/vnstat.db $BACKUP_DIR/vnstat.db-$DATE.bkp

# Delete vnstat backup files older than 3 days #
find $BACKUP_DIR/*.bkp -mtime +3 -exec rm {} \;

#Remove new_device file
rm /tmp/new_device.out

#NOTE: Please update the interface so it matches your router. 
# If its the first of the month, it will drop the interface. 
if [ `date +%d` = "01" ]
then
    vnstat --remove -i wlan-sta0 --force
    vnstat --add -i wlan-sta0
    /etc/init.d/vnstat restart

else
    echo "not first of the month"
fi



