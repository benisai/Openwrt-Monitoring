#!/bin/sh

router=10.0.5.1

# Netify Log File Location
FILE=/var/log/netify/netify.log
# How many seconds before file is deemed "older"
OLDTIME=30
# Get current and file times
CURTIME=$(date +%s)
FILETIME=$(stat $FILE -c %Y)
TIMEDIFF=$(expr $CURTIME - $FILETIME)

##########--Create Netify Folder and File---########
if [ ! -f /var/log/netify/netify.log ]; then
  mkdir -p /var/log/netify
  touch /var/log/netify/netify.log
fi

# Check if file older
if [ $TIMEDIFF -gt $OLDTIME ]; then
  echo "File is older, restarting Netify.log"
  ##########################--Kill any existing NetCat--#########################
  PIDS=$(ps -eaf | grep $router | grep -v grep | awk '{print $2}')
  echo "Netify Netcat Was Found, PID: " $PIDS
  for PID in $PIDS; do
    echo "Killing Process" $PID
    kill -9 $PID 1>&2
  done

    #########################--Start NetCat--#####################################
  PIDS=$(ps -eaf | grep $router | grep -v grep | awk '{print $2}')
  if [ -z "$PIDS" ]; then
    echo "Netify Netcat Process is Not Running." 1>&2
    echo "Starting Netify Netcat Process"
    sleep 1000 | nc $router 7150 | grep established | sed 's/"established":false,//g; s/"flow":{//g; s/0}/0/g' | (sed '
        s/0.0.0.0/TEMP/g;
        s/0.0.0.1/END/g') >>/var/log/netify/netify.log &


            PIDS=$(ps -eaf | grep $router | grep -v grep | awk '{print $2}')
    echo New Netify Netcat PID $PIDS
    exit 1
  else
    for PID in $PIDS; do
      echo Netify is running, PID is $PID
    done
  fi
else
  PIDS=$(ps -eaf | grep $router | grep -v grep | awk '{print $2}')
  echo "Netify PID: " $PIDS
  for PID in $PIDS; do
    echo "Netify Process" $PID
  done
  echo Netify.log is current $FILETIME
fi
