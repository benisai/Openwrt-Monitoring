#!/bin/sh
#Get WAN Address from Router
. /lib/functions/network.sh; network_find_wan NET_IF; network_get_ipaddr WAN_ADDR "${NET_IF}";

#Get Public IP address from Internet
cip=$(curl https://api.ipify.org) > /dev/null 2>&1

#Ping to see if we have internet
pg=$(ping -c 3 8.8.8.8 > /dev/null && echo "1" || echo "0")

echo "${WAN_ADDR}" "${cip}" "${pg}" > /tmp/wantest.out
