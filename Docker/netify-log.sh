#!/bin/sh

#########################--Kill any existing NetCat--#########################
PID=`ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}'`
if test -d /proc/"$PID"/; then
    echo "Netify Netcat Process Found, killing Process" $PID
    kill -9 $PID 1>&2
fi

#########################--Start NetCat--#########################
PIDS=`ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}'`
if [ -z "$PIDS" ]; then
  echo "Netify Netcat Process is Not Running." 1>&2
  echo "Starting Netify Netcat Process"
  sleep 1000 | nc 10.0.5.1 7150 | grep established | sed 's/"established":false,//g; s/"flow":{//g; s/0}/0/g'   >> /var/log/netify/netify.log &
  PIDS=`ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}'`
  echo New Netify Netcat PID $PIDS
  exit 1
else
  for PID in $PIDS; do
    echo Netify is running,  PID is $PIDS
  done
fi
