#!/bin/sh
# set -x
#wrtbwmon script will run every
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
sleep 2
cat /tmp/usage.htm | grep "2022" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()'  > usage.out
