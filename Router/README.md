# Router Scripts and Lua Files




On the router, the following scripts and prometheus Lua files are used. The Scripts will output "Reports" to /tmp/ location as *.out. The Prometheus lua files will read these "Reports.out" files and parse the data for prometheus to scrape. 

In the Scripts folder:
  >1-hour-script.sh - mainly used to restart netify
  
  >1-min-script.sh - Get your WanIP, Run VNstat monthly report, Restart Netify if service is not running
  
  >5-min-script.sh - Get your WanIP, Run VNstat monthly report, Restart Netify if service is not running
  
  >12am-script.sh - Backup vnstat.db, Remove new_device file, and if its the 1st of the month, drop vnstat DB
  
  >device-status-ping.sh -- Ping devices on network to see if they are online
  
  >new_device.sh -- Check if new devices are found on network (WIP Doesnt work yet)
  
  >packet-loss.sh -- This will monitor packetloss by pinging google 40 times a minute and gather the packetloss rate
  
  >speedtest.sh -- This is a speedtest script created by someone else, if this doesnt run its because the 3rd party speed test blocked your ip. 


 
