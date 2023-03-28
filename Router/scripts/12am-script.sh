#!/bin/bash
DATE=$(date +%m-%d-%Y)
BACKUP_DIR="/etc/backup"
BACKUP_DIR="/tmp/mountd/disk1_part1"

# backup the vnstat.db and bwmon.db and add a timestamp to the file
cp  /var/lib/vnstat/vnstat.db $BACKUP_DIR/vnstat.db-$DATE.bkp
cp  /tmp/usage.db $BACKUP_DIR/usage.db-$DATE.bkp

# Delete vnstat backup files older than 3 days #
find $BACKUP_DIR/*.bkp -mtime +3 -exec rm {} \;

#Remove new_device file
rm /tmp/new_device.out
touch /tmp/new_device.out


###----If its the first of the month, drop the vnstat interface and recreate----###
#Find WAN Interface for vnstat to monitor
gateway_ip=$(ip route | awk '/default/ {print $3}')
wan_iface=$(ip route | awk -v ip="$gateway_ip" '$0~ip {print $5}')

#Get Date
bi=$(date +%d)
if [ $bi = "01" ]
then
    vnstat --remove -i $wan_iface --force
    vnstat --add -i $wan_iface
    /etc/init.d/vnstat restart

else
    echo "It is not the 1st of the month, so vnstat will not drop the interface to recreate"
fi
