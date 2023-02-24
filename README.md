
## Intro
* This project consists of a few applications to help monitor your home router. You will need a decent router (anything from 2-3yrs ago will work) with dual core CPU, with 256mb-512mb of RAM and 128mb nand. 
  * Note: This will only work with Openwrt 21.x (IPTables). NFTables will not be supported as IPTmon uses iptables. You can still run this project, but you wont get stats per device. 
  * Please keep in mind. I created this repo to store my project files/config somewhere so I can look back at it later (personal use). Feel free to use it but modify the config files to your environment (IP addresses)
```
* Here are some features of this project
  * Internet monitoring via pings to google/quad9/Cloudflare
  * Packetloss monitoring via shell script, pinging google 40 times
  * Speedtest monitoring -- (kind of a hit/miss, I'll explain below)
  * DNS Stats via AdguardHome
  * GeoIP Map for Destnation (provided by Netify logs, Check out the netify-log.sh script in the Docker folder https://github.com/benisai/Openwrt-Monitoring/blob/main/Docker/netify-log.sh)
  * Device Traffic Panel (provided by Netify logs). Src + Dst + Port + GeoInfo 
  * Device Status (Hostname + IP + Status Online or Offline)
  * System Resources monitoring (CPU/MEM/Load/Etc)
  * Monthly Bandwidth monitoring (Will clear monthly)
  * 12hr Traffic usage
  * WAN Speeds
  * Live traffic per device (iptmon)
  * Traffic per client usage for 2hr
  * Ping Stats
  * Hourly traffic usage (iptmon total)
  * 7 Day traffic usage (iptmon total)
  * New Devices Connected to Network
  * Destnation IP count
  * Destnation Port count
  * NAT Traffic (Not really used anymore)
* We need to install a few pieces of software + custom shell scripts on the router to collect this data  
```

</br>
</br>

## Software Used to Monitor Traffic
### Home Server (Linux)
* Home Server running Docker + Docker-Compose
  Note:  I provided a Docker-Compose.yml file with all the containers needed for the project
  * Prometheus - Container to scrape and store data.
  * Grafana - Container to display the graphs. (you will need to add your Prometheus location as the data source)
  * Loki + Promtail + Middleware - Containers used to collect and process Netify logs created by netify-log.sh
  * AdGuardHome - Container to block Ads/Porn/etc.
  * Collectd-exporter - Container to collect data from Collectd on the Router
  * Adguard-exporter - Container to collect data from AdGuardHome

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

## Installation
### Home Server (Linux)

* Clone this repo to your server. 
```sh
   gh repo clone benisai/Openwrt-Monitoring
   cd Openwrt-Monitoring
   sudo nano prometheus.yml 
    * replace 10.0.5.1 with your Router IP
   sudo nano netify-log.sh 
    * replace 10.0.5.1 with your Router IP
   sudo docker network create internal
   sudo Docker-Compose.yml up -d
```
  * Setup netify-log.sh script
```sh
   sudo crontab -e
   Add the following line:  */1 * * * * /home/USER/Openwrt-Monitoring/Docker/netify-log.sh >> /var/log/crontab.netify.txt 2>&1  
   sudo chmod +x /home/USER/Openwrt-Monitoring/Docker/netify-log.sh  
   sudo nano /home/USER/Openwrt-Monitoring/Docker/netify-log.sh and replace the IP + hostname for each device
```
</br>

### Router Setup (Openwrt 21.x)
* Download the shell script to setup the router
  * wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/routersetup.sh
    * nano routersetup.sh
      * replace 10.0.5.5 with your Home Server IP
* sh routersetup.sh
  * Reboot Router

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



