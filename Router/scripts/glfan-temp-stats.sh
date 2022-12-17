#!/bin/sh
temp=`cat /sys/class/thermal/thermal_zone0/temp`
speed=`gl_fan -s`
state=`cat /sys/class/thermal/cooling_device0/cur_state`
echo "$temp $speed" > /tmp/tempstats.out
