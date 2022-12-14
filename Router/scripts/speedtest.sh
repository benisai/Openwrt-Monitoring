#! /bin/sh
# Copyright (c) 2014-2022 - Rich Brown rich.brown@blueberryhillsoftware.com
# GPLv2


summarize_pings() {     
  
grep "time" < "$1" | cat | \
sed 's/^.*time=\([^ ]*\) ms/\1/'| \
  # tee >&2 | \
  sort -n | \
  awk 'BEGIN {numdrops=0; numrows=0} \
    { \
      # print ; \
      if ( $0 ~ /timeout/ ) { \
          numdrops += 1; \
      } else { \
        numrows += 1; \
        arr[numrows]=$1; sum+=$1; \
      } \
    } \
    END { \
      pc10="-"; pc90="-"; med="-"; \
      if (numrows == 0) {numrows=1} \
      if (numrows>=10) \
      { # get the 10th pctile - never the first one
        ix=int(numrows/10); if (ix=1) {ix+=1}; pc10=arr[ix]; \
        # get the 90th pctile
        ix=int(numrows*9/10);pc90=arr[ix]; \
        # get the median
        if (numrows%2==1) med=arr[(numrows+1)/2]; else med=(arr[numrows/2]); \
      }; \
      pktloss = numdrops/(numdrops+numrows) * 100; \
      printf("\n  Latency: (in msec, %d pings, %4.2f%% packet loss)\n      Min: %4.3f \n    10pct: %4.3f \n   Median: %4.3f \n      Avg: %4.3f \n    90pct: %4.3f \n      Max: %4.3f\n", numrows, pktloss, arr[1], pc10, med, sum/numrows, pc90, arr[numrows] )\
      
     }'
}


# set an initial values for defaults
TESTHOST="netperf.bufferbloat.net"
TESTDUR="60"

PING4=ping
command -v ping4 > /dev/null 2>&1 && PING4=ping4
PING6=ping6

PINGHOST="gstatic.com"
MAXSESSIONS=4
TESTPROTO=-4

# Create temp files for netperf up/download results
ULFILE=`mktemp /tmp/netperfUL.XXXXXX` || exit 1
DLFILE=`mktemp /tmp/netperfDL.XXXXXX` || exit 1
PINGFILE=`mktemp /tmp/measurepings.XXXXXX` || exit 1
# echo $ULFILE $DLFILE $PINGFILE

# read the options

# extract options and their arguments into variables.
while [ $# -gt 0 ] 
do
    case "$1" in
	    -4|-6) TESTPROTO=$1; shift 1 ;;
        -H|--host)
            case "$2" in
                "") echo "Missing hostname" ; exit 1 ;;
                *) TESTHOST=$2 ; shift 2 ;;
            esac ;;
        -t|--time) 
        	case "$2" in
        		"") echo "Missing duration" ; exit 1 ;;
                *) TESTDUR=$2 ; shift 2 ;;
            esac ;;
        -p|--ping)
            case "$2" in
                "") echo "Missing ping host" ; exit 1 ;;
                *) PINGHOST=$2 ; shift 2 ;;
            esac ;;
        -n|--number)
        	case "$2" in
        		"") echo "Missing number of simultaneous sessions" ; exit 1 ;;
        		*) MAXSESSIONS=$2 ; shift 2 ;;
        	esac ;;
        --) shift ; break ;;
        *) echo "Usage: sh Netperfrunner.sh [ -H netperf-server ] [ -t duration ] [ -p host-to-ping ] [ -n simultaneous-streams ]" ; exit 1 ;;
    esac
done

# Start main test

if [ $TESTPROTO -eq "-4" ]
then
	PROTO="ipv4"
else
	PROTO="ipv6"
fi
DATE=`date "+%Y-%m-%d %H:%M:%S"`

# Start Ping
if [ $TESTPROTO -eq "-4" ]
then
	"${PING4}" $PINGHOST > $PINGFILE &
else
	"${PING6}" $PINGHOST > $PINGFILE &
fi
ping_pid=$!
# echo "Ping PID: $ping_pid"

# Start $MAXSESSIONS upload datastreams from netperf client to the netperf server
for i in $( seq $MAXSESSIONS )
do
	netperf $TESTPROTO -H $TESTHOST -t TCP_STREAM -l $TESTDUR -v 0 -P 0 >> $ULFILE &
	# echo "Starting upload #$i $!"
done

# Start $MAXSESSIONS download datastreams from netperf server to the client
for i in $( seq $MAXSESSIONS )
do
	netperf $TESTPROTO -H $TESTHOST -t TCP_MAERTS -l $TESTDUR -v 0 -P 0 >> $DLFILE &
	# echo "Starting download #$i $!"
done


for i in `pgrep -P $$ netperf`		# get a list of PIDs for child processes named 'netperf'
do
	# echo "Waiting for $i"
	wait $i
done

# Stop the pings after the netperf's are all done
kill -9 $ping_pid
wait $ping_pid 2>/dev/null


DL=`awk '{s+=$1} END {print s}' $DLFILE`
UL=`awk '{s+=$1} END {print s}' $ULFILE`
echo "${DL}" "${UL}" > /tmp/speedtest.out

#summarize_pings $PINGFILE

# Clean up
rm $PINGFILE
rm $DLFILE
rm $ULFILE

sleep 60
rm /tmp/speedtest.out
