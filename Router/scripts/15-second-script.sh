#!/bin/sh
# set -x

#wrtbwmon script will run every
wrtbwmon update /tmp/usage.db
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
sleep 1
cat /tmp/usage.htm | grep "2022" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()' | sed '$d' > /tmp/bwmon_usage.out
