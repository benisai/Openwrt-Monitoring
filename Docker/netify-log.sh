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
        s/10.0.5.120/AI-CAM/g;
        s/10.0.5.121/LivingRoom-CAM/g;
        s/10.0.5.131/Bens-iPhone/g;
        s/10.0.5.3/FWP-SE/g;
        s/10.0.5.5/Home-Server/g;
        s/10.0.5.223/vw-logs/g;
        s/10.0.5.122/EI-CAM/g;
        s/10.0.5.170/Chelsea-iPhone/g;
        s/10.0.5.119/Nest/g;
        s/10.0.5.146/Bens-iPad/g;
        s/10.0.5.110/tasmotapc-0095/g;
        s/10.0.5.238/SYN-Datto/g;
        s/10.0.5.144/Bens-Air/g;
        s/10.0.5.10/Synology/g;
        s/10.0.5.141/Chromecast/g;
        s/10.0.5.112/tasmotaOL1-0312/g;
        s/10.0.5.239/Pixel-7/g;
        s/10.0.5.229/Datto/g;
        s/110.0.5.214/Chelsea-Air/g;
        s/10.0.5.238/Syn-Datto/g;
        s/10.0.5.10/Synology/g;
        s/10.0.5.11/MeLe-WiFi/g;
        s/10.0.5.111/tasmotaOL3-5016/g;
        s/10.0.5.113/tasmotaOL2-2268/g') >>/var/log/netify/netify.log &


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
