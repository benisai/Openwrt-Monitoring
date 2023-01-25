#!/bin/sh
PIDS=`ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}'`

if [ -z "$PIDS" ]; then
  echo "Process not running." 1>&2
  echo "Starting Netify"
  #sleep 1000 | nc 10.0.5.1 7150 | grep established  >> /var/log/netify.log &
  #sleep 1000 | nc 10.0.5.1 7150 | grep established | tr -d '"' | sed 's/:/=/g; s/,/ /g'  >> /var/log/netify.log &
  sleep 1000 | nc 10.0.5.1 7150 | grep established | sed 's/"established":false,//g; s/"flow":{//g; s/0}/0/g'   >> /var/log/netify.log &
  PIDS=`ps -eaf | grep "10.0.5.1" | grep -v grep | awk '{print $2}'`
  echo new PID is $PIDS
  exit 1
else
  for PID in $PIDS; do
    echo Netify is running,  PID is $PID
  done
fi