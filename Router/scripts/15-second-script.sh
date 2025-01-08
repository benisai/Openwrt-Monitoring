#!/bin/sh
# set -x
#---------------------------------------------------------------------------------------------------------#


#---------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------#
# Network Clients Discovery Script for OpenWRT
OUTPUT_FILE="/tmp/clientlist.out"
LEASES_FILE="/tmp/dhcp.leases"
ARP_FILE="/proc/net/arp"
# Remove the output file if it exists
[ -f "$OUTPUT_FILE" ] && rm "$OUTPUT_FILE"
# Create a fresh output file
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

