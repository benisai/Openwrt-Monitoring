#!/bin/sh

# Initialize variables
internet_working=1
start_time=0

# Set the path to the log file
log_file="/tmp/wan_monitor.log"

if [ -f "$log_file" ]; then
  rm "$log_file"
fi

while true; do
    # Ping Google DNS server
    ping -c 1 10.0.5.225 > /dev/null 2>&1

    # Check if ping was successful
    if [ $? -eq 0 ]; then
        # Internet is working
        if [ $internet_working -eq 0 ]; then
            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))
            echo "$(date '+%Y-%m-%d-%H:%M:%S') Internet_is_working $elapsed_time" >> $log_file
            internet_working=1
        fi
    else
        # Internet is not working
        if [ $internet_working -eq 1 ]; then
            start_time=$(date +%s)
            echo "$(date '+%Y-%m-%d-%H:%M:%S') Internet_is_down 999999" >> $log_file
            internet_working=0
        fi

        # Increment seconds
        seconds=$((seconds+10))
    fi

    # Wait for 1 second before pinging again
    sleep 1

done
