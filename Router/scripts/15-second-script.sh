#!/bin/sh
# set -x
#---------------------------------------------------------------------------------------------------------#
#wrtbwmon script will run every
wrtbwmon update /tmp/usage.db
wrtbwmon publish /tmp/usage.db /tmp/usage.htm
cat /tmp/usage.htm | grep "2024" | sed 's/,/  /g; s/"//g; s/new Array//g' | tr -d '()' | sed '$d' > /tmp/bwmon_usage.out

#---------------------------------------------------------------------------------------------------------#
#Get Temp and Fan speed for GL-Routers
temp=`cat /sys/class/thermal/thermal_zone0/temp`
speed=`gl_fan -s`
echo "$temp $speed" > /tmp/tempstats.out

#---------------------------------------------------------------------------------------------------------#

# Network Clients Discovery Script for OpenWRT
OUTPUT_FILE="/tmp/clientlist.out"
LEASES_FILE="/tmp/dhcp.leases"
ARP_FILE="/proc/net/arp"

# Parse DHCP leases
if [ -f "$LEASES_FILE" ]; then
    while read -r timestamp mac ip hostname id; do
        [ -z "$ip" ] && continue
        [ "$hostname" = "*" ] && hostname="Unknown"
        printf "%-20s %-17s %-15s %-20s\n" "$hostname" "$mac" "$ip" "DHCP Lease" >> "$OUTPUT_FILE"
    done < "$LEASES_FILE"
else
    echo "DHCP leases file not found: $LEASES_FILE" >> "$OUTPUT_FILE"
fi

# Parse ARP table for additional clients
if [ -f "$ARP_FILE" ]; then
    awk 'NR>1 {print $1, $4}' "$ARP_FILE" | while read -r ip mac; do
        if ! grep -q "$ip" "$LEASES_FILE"; then
            printf "%-20s %-17s %-15s %-20s\n" "Unknown" "$mac" "$ip" "ARP Only" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "ARP file not found: $ARP_FILE" >> "$OUTPUT_FILE"
fi

ln -s $OUTPUT_FILE /www/clientlist.html
#---------------------------------------------------------------------------------------------------------#

