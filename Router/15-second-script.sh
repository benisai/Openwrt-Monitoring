#!/bin/sh
# set -x

while true
do
#---start line---#
now=$(date +"%T")

#wrtbwmon script will run every
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
sleep 1
cat /tmp/usage.htm | grep "2022" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()' | sed '$d' > /tmp/bwmon_usage.out


#---end line---#
sleep 14
done
