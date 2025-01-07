#!/bin/sh
# set -x
#---------------------------------------------------------------------------------------------------------#
#wrtbwmon script will run every
wrtbwmon update /tmp/usage.db
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
cat /tmp/usage.htm | grep "2025" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()' | sed '$d' > /tmp/bwmon_usage.out

#---------------------------------------------------------------------------------------------------------#
#Get Temp and Fan speed for GL-Routers
temp=`cat /sys/class/thermal/thermal_zone0/temp`
speed=`gl_fan -s`
echo "$temp $speed" > /tmp/tempstats.out

#---------------------------------------------------------------------------------------------------------#
