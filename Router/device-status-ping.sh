#!/bin/sh

IFS=$IFS
while read time mac ip name bs; do
    ping -c1 "$ip" &>/dev/null && echo device=$name mac=$mac ip=$ip status=online || echo device=$name mac=$mac ip=$ip status=offline
done < /tmp/dhcp.leases > /tmp/device-status.out
