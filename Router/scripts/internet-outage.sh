#!/bin/sh

# Initialize variables
internet_working=1
start_time=0

# Set the path to the log file
log_file="/tmp/wan_monitor.log"

# Delete log file if it exists
#if [ -f "$log_file" ]; then
#  rm "$log_file"
#fi

while true; do
    # Ping DNS server
    ping -c 1 8.8.8.8 2>&1 > /dev/null

    # Check if ping was successful
    if [ $? -eq 0 ]; then
        # Internet is working (iiw)
        if [ $internet_working -eq 0 ]; then
            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))
            #Create a new file, with the down message and up message in 1 line.
            upmsg="$(date '+%Y-%m-%d-%H:%M:%S') up $elapsed_time"
            sed -i "s/UP_MSG/$upmsg/g" $log_file #> $log_file.tmp && mv $log_file.tmp $log_file
            internet_working=1
        fi
    else
        # Internet is not working (iid)
        if [ $internet_working -eq 1 ]; then
            start_time=$(date +%s)
            echo "$(date '+%Y-%m-%d-%H:%M:%S') down UP_MSG " >> $log_file
            internet_working=0
        fi

        # Increment seconds
        seconds=$((seconds+10))
    fi
    
    
    # Wait for 1 second before pinging again
    sleep 1

done
