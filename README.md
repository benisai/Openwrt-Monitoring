
## Intro
* This project consists of a few applications to help monitor your Openwrt router. You will need a decent router (anything from 2-3yrs ago will work) with dual core CPU, with 256mb-512mb of RAM and 128mb nand. 
  * Note: This will only work with Openwrt 21.x (IPTables). NFTables will not be supported as IPTmon uses iptables. You can still run this project, but you wont get stats per device. 
  * Please keep in mind. I created this repo to store my project files/config somewhere so I can look back at it later (personal use). Feel free to use it but modify the config files to your environment (IP addresses)
```
* Here are some features of this project
  * Internet monitoring via pings to google/quad9/Cloudflare
  * Packetloss monitoring via shell script, pinging google 40 times
  * Speedtest monitoring via shell script -- (kind of broken, hit/miss, I'll explain below)
  * DNS Stats via AdguardHome Container in Docker
  * GeoIP Map for Destnation (provided by Netify logs, Check out the netify-log.sh script in the Docker folder https://github.com/benisai/Openwrt-Monitoring/blob/main/Docker/netify-log.sh)
  * Device Traffic Panel via netify-log.sh (provided by Netify logs). Src + Dst + Port + GeoInfo 
  * Device Status (Hostname + IP + Status Online or Offline)
  * System Resources monitoring (CPU/MEM/Load/Etc) via prometheus on Router
  * Monthly Bandwidth monitoring via VNState2 (Will clear monthly on 1st via crontab)
  * 12hr Traffic usage (calucated by itpmon results from prometheus)
  * WAN Speeds via prometheus
  * Live traffic per device (iptmon)
  * Traffic per client usage for 2hr (calucated by itpmon results from prometheus)
  * Ping Stats via CollectD
  * Hourly traffic usage (calucated by itpmon results from prometheus)
  * 7 Day traffic usage (calucated by itpmon results from prometheus)
  * New Devices Connected to Network via shell script
  * Destnation IP count (calucated by nat_traffic results from prometheus)
  * Destnation Port count (calucated by nat_traffic results from prometheus)
  * NAT Traffic (calucated by nat_traffic results from prometheus)
* We need to install a few pieces of software + custom shell scripts on the router to collect this data  
```

</br>
</br>

## Software Used to Monitor Traffic
### Home Server (Ubuntu)
* Ubuntu Home Server running Docker + Docker-Compose
  Note:  I provided a Docker-Compose.yml file with all the containers needed for the project
  * Prometheus - Container to scrape and store data.
  * Grafana - Container to display the graphs. (you will need to add your Prometheus location as the data source)
  * Loki + Promtail + Middleware - Containers used to collect and process Netify logs created by netify-log.sh
  * AdGuardHome - Container to block Ads/Porn/etc.
  * Collectd-exporter - Container to collect data from Collectd on the Router
  * Adguard-exporter - Container to collect data from AdGuardHome
  * Netify-log.sh - This will create a netcat connection to netifyd running on the router, it will output a local json log 

### Router
* Openwrt Router (21.x)
  * Custom shell scripts to collect / output data to report files 
    * 1-hour-script.sh - mainly used to restart netify
    * 1-min-script.sh - Get your WanIP, Run VNstat monthly report, Restart Netify if service is not running
    * 5-min-script.sh - Not used at the moment
    * 12am-script.sh - Backup vnstat.db, Remove new_device file, and if its the 1st of the month, drop vnstat DB
    * device-status-ping.sh -- Ping devices on network to see if they are online
    * new_device.sh -- Check if new devices are found on network (WIP Doesnt work yet)
    * packet-loss.sh -- This will monitor packetloss by pinging google 40 times a minute and gather the packetloss rate
    * speedtest.sh -- This is a speedtest script created by someone else, if this doesnt run its because the 3rd party speed test blocked your ip.
  * Prometheus - main router monitoring (CPU,MEM,etc) with custom Prometheus Lua Files
  * Collectd - to monitor ping and export iptmon data
  * vnstat2 - to monitor monthly WAN Bandwidth usage (12am-Script.sh will check if its the 1st of the month and drop the vnstatdb)
  * iptmon - to monitor per device usage
  * Netifyd - Netify Agent is a deep-packet inspection server which detects network\\ protocols and applications.


</br>
</br>


![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard1.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard2.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard3.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard4.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard5.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard6.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard7.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard8.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard9.PNG)


</br>
</br>



## Installation (pt1 Linux Server, pt2 Openwrt)
### Home Server (Linux)

* Clone this repo to your server. 
```
   sudo wget https://github.com/benisai/Openwrt-Monitoring/blob/main/serverSetup.sh
   run 'sudo nano ./serverSetup.sh' and update the router_ip variable.
   run 'sudo chmod +x ./serverSetup.sh'
   run 'sudo ./serverSetup.sh'
   This command will ask if you want to install docker, if its already installed, it will be skipped 
```

  * Create Crontab config on Server (replace USER with your username for the Cronjobs)
    
   run 'sudo crontab -e'  and add the line below. 
```   
   */1 * * * * /home/USER/Openwrt-Monitoring/Docker/netify-log.sh >> /var/log/crontab.netify.txt 2>&1
```

</br>

-------------------------------------------------------------------------------

### Router Setup (Openwrt 21.x)
* Download the shell script to setup the router
  * ```wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/routersetup.sh```
    * nano routersetup.sh
      * replace 10.0.5.5 with your Home Server IP
* ```sh routersetup.sh```
* Note: I removed the interface dns as it was causing some issues if you dont have Adguard home running on your docker server. if you do, uncomment the dns part if the script so Adguard home can see the hostnames of the devices. 

=============================================================================
* Configure Collectd on Router
  * Licu -> Statistics -> Setup ->
  * Collectd Settings:
      * Set the Data collection interval to 10 seconds
  * Network plugins:
      * Configure the Ping (1.1.1.1, 8.8.8.8, 9.9.9.9)
      * Configure the Firewall plugin (See screenshot https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/CollectD1-firewall.PNG)
  * Output plugins:
      * Configure Network -> Server interfaces (add your home server ip ex.10.0.5.5) (see screenshot https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Collectd-output.PNG)
   
=============================================================================  
* Configure Netify.d on Router
  * SSH into router
  * You have to add your routers IP address to Socket section below to enable TCP sockets in the netifyd engine.
  * nano /etc/netifyd.conf
    * (replace 10.0.5.1 with your routers IP address)
      <pre>
      [socket]
      listen_path[0] = /var/run/netifyd/netifyd.sock
      listen_address[0] = 10.0.5.1    <---------Add this line, update the Router IP
      </pre>
  * Reboot Router

=============================================================================

<pre>
The routersetup.sh script will do the following:
* Install Nano, netperf (needed for speedtest.sh), openssh-sftp-server,vnstat
* Install Prometheus and CollectD
* Install iptmon, wrtbwmon and luci-wrtbwmon
* Copy custom scripts from this git to /usr/bin/ on the router
* Copy custom LUA files from this git to /usr/lib/lua/prometheus-collectors on the router.
* Adding new_device.sh script to dhcp dnsmasq
* Adding scripts to Crontab
* Update prometheus config to 'lan'
* Update Collectd Export IP to home server ip address
* Add iptmon to your dhcp file under dnsmasq section
* Set your lan interface to assign out DNS IP of your home server
* restarts services
</pre>


--------

Credit: I have to give credit to Matthew Helmke, I used his blog and grafana dashboard and I added some stuff. I cant say I'm an expert in Grafana or Prometheus (first time using Prom) https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/



