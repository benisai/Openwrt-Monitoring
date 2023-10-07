#!/bin/sh

# Initialize variables
internet_working=1
start_time=0

# Set the path to the log file
log_file="/tmp/wan_monitor.log"

while true; do
    # Ping DNS server
    ping -c 1 8.8.8.8 2>&1 > /dev/null

    # Check if ping was successful
    if [ $? -eq 0 ]; then
        # Internet is working (iiw)
        if [ $internet_working -eq 0 ]; then
            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))

            # Only write to the log file if the outage lasted longer than 5 seconds
            if [ $elapsed_time -ge 10 ]; then
                upmsg="$(date '+%Y-%m-%d-%H:%M:%S') up $elapsed_time"
                sed -i "s/placeholder/$upmsg/g" $log_file
            fi

            internet_working=1
        fi
    else
        # Internet is not working (iid)
        if [ $internet_working -eq 1 ]; then
            start_time=$(date +%s)
            echo "$(date '+%Y-%m-%d-%H:%M:%S') down placeholder " >> $log_file
            internet_working=0
        fi
    fi
    
    # Wait for 1 second before pinging again
    sleep 1
done
