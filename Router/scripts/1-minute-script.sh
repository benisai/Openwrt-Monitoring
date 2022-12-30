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
vnstat --xml |grep -hnr "month id" | sed 's/<[^>]*>/ /g; s/2022//g; s/        //g' | cut -d " " -f2- | cut -d " " -f2- > /tmp/vnstatmonth.out
#vnstat --xml |grep -hnr "month id" | sed 's/<[^>]*>/ /g; s/2022//g; s/        //g' | cut -d " " -f2- > /tmp/monthoutput.out
#vnstat --xml |grep -hnr "day id" | sed 's/<[^>]*>/ /g; s/2022//g; s/        //g' | cut -d " " -f2- > /tmp/dayoutput.out
#vnstat --xml |grep -hnr "hour id" | sed 's/<[^>]*>/ /g; s/2022//g; s/        //g; s/  00/:00/g' | cut -d " " -f2-  > /tmp/houroutput.out
#vnstat --xml |grep -hnr "fiveminute id" | sed 's/<[^>]*>/ /g; s/2022//g; s/        //g' | cut -d " " -f2-   > /tmp/fiveoutput.out


sleep 1
####PacketLoss
packet=$(ping -c 20 8.8.8.8 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}' | sed 's/%//g')
echo "$packet" > /tmp/packetloss.out
