#!/bin/sh
# set -x

#wrtbwmon script will run every
wrtbwmon update /tmp/usage.db
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
cat /tmp/usage.htm | grep "2023" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()' | sed '$d' > /tmp/bwmon_usage.out

#Get Temp and Fan speed for GL-Routers
temp=`cat /sys/class/thermal/thermal_zone0/temp`
speed=`gl_fan -s`
echo "$temp $speed" > /tmp/tempstats.out

#Kill Netify Output and Restart Output
#ps | grep 7150 | grep -v grep | awk '{print $1}' | xargs kill
#sleep 15000 | nc 10.0.5.1 7150 | grep established | tr -d '"' | sed 's/:/=/g; s/,/ /g'   > /tmp/netify.out &
