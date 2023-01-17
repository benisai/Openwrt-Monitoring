#!/bin/sh
logread | grep "received args: add" | awk '{print $1, $2, $3, $4, $11, $12, $13}' > /tmp/newd.tmp

IFS=$IFS
while read day m d t mac ip name; do
    echo time=$day-$m-$d-$t device=$name mac=$mac ip=$ip
done < /tmp/newd.tmp > /tmp/new-device.txt
