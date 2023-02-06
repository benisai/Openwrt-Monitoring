#!/bin/sh

####WanIP
#Get WAN Address from Router
. /lib/functions/network.sh; network_find_wan NET_IF; network_get_ipaddr WAN_ADDR "${NET_IF}";
#Get Public IP address from Internet
cip=$(curl https://api.ipify.org) > /dev/null 2>&1
#Echo to File
echo "wanip=${WAN_ADDR}" "publicip=${cip}" >/tmp/wanip.out
sleep 1

#vnstat update DB
vnstat -u
sleep 1

#####Run vnstat and parse output
vnstat --xml |grep -hnr "month id" | sed 's/<[^>]*>/ /g; s/2023//g; s/        //g' | cut -d " " -f2- | cut -d " " -f2- > /tmp/vnstatmonth.out
#vnstat --xml |grep -hnr "month id" | sed 's/<[^>]*>/ /g; s/2023//g; s/        //g' | cut -d " " -f2- > /tmp/monthoutput.out
#vnstat --xml |grep -hnr "day id" | sed 's/<[^>]*>/ /g; s/2023//g; s/        //g' | cut -d " " -f2- > /tmp/dayoutput.out
#vnstat --xml |grep -hnr "hour id" | sed 's/<[^>]*>/ /g; s/2023//g; s/        //g; s/  00/:00/g' | cut -d " " -f2-  > /tmp/houroutput.out
#vnstat --xml |grep -hnr "fiveminute id" | sed 's/<[^>]*>/ /g; s/2023//g; s/        //g' | cut -d " " -f2-   > /tmp/fiveoutput.out

#Kill Netify Output and Restart Output
ps | grep 7150 | grep -v grep | awk '{print $1}' | xargs kill
rm /tmp/netify.out
service netifyd restart
sleep 1000 | nc 10.0.5.1 7150 | grep established | tr -d '"' | sed 's/:/=/g; s/,/ /g'   >> /tmp/netify.out &


