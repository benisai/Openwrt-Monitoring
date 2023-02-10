#!/bin/sh
# Input file

##########--Create Netify Folder and File---########
if [ ! -f /var/log/netify/netify.log ]; then
  mkdir -p /var/log/netify
  touch /var/log/netify/netify.log
fi

FILE=/var/log/netify/netify.log
# How many seconds before file is deemed "older"
OLDTIME=300
# Get current and file times
CURTIME=$(date +%s)
FILETIME=$(stat $FILE -c %Y)
TIMEDIFF=$(expr $CURTIME - $FILETIME)

# Check if file older
if [ $TIMEDIFF -gt $OLDTIME ]; then
  echo "File is older, restarting Netify.log"
  ##########################--Kill any existing NetCat--#########################
  PID=$(ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}')
  echo "Netify Netcat Was Found, PID: " $PID
  if test -d /proc/"$PID"/; then
    echo "Netify Netcat Process Found, killing Process" $PID
    kill -9 $PID 1>&2
  fi
  #########################--Start NetCat--#####################################
  PIDS=$(ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}')
  if [ -z "$PIDS" ]; then
    echo "Netify Netcat Process is Not Running." 1>&2
    echo "Starting Netify Netcat Process"
    sleep 1000 | nc 10.0.5.1 7150 | grep established | sed 's/"established":false,//g; s/"flow":{//g; s/0}/0/g' >>/var/log/netify/netify.log &
    #sleep 1000 | nc 10.0.5.1 7150 | grep established | sed 's/"established":false,//g; s/"flow":{//g; s/0}/0/g; s/:/=/g; s/,/ /g; s/"//g'   >> /var/log/neti>
    PIDS=$(ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}')
    echo New Netify Netcat PID $PIDS
    exit 1
  else
    for PID in $PIDS; do
      echo Netify is running, PID is $PID
    done
  fi
else
  echo Netify.log is current $FILETIME
fi
