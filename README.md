
## Intro
* This project consists of a few applications to help monitor your home router. You will need a decent router (anything from 2-3yrs ago will work) with dual core CPU, with 256mb-512mb of RAM and 128mb nand. Note: This will only work with Openwrt 21.x (IPTables). NFTables will not be supported as IPTmon uses iptables. You can still run this project, but you wont get stats per device. 


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
  * Prometheus - main router monitoring (CPU,MEM,etc) with custom Prometheus Lua Files
  * Collectd - to monitor ping and export iptmon data
  * vnstat2 - to monitor monthly WAN Bandwidth usage (12am-Script.sh will check if its the 1st of the month and drop the vnstatdb)
  * iptmon - to monitor per device usage


---------------------------------------------------------------
<br>

![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard1.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard2.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard3.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard4.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard5.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard6.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard7.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard8.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard9.PNG)



## Installation
### Home Server (Linux)
* Clone this repo to your server. 
  * gh repo clone benisai/Openwrt-Monitoring
  * cd Openwrt-Monitoring
  * sudo nano prometheus.yml 
    * replace 10.0.5.1 with your Router IP
  * sudo nano netify-log.sh 
    * replace 10.0.5.1 with your Router IP
  * sudo docker network create internal
  * sudo Docker-Compose.yml up -d

* Create a Crontab -e to run the netify-log.sh script
  * sudo crontab -e
    * */1 * * * * /home/USER/Openwrt-Monitoring/Docker/netify-log.sh >> /var/log/crontab.netify.txt 2>&1
  * sudo chmod +x /home/USER/Openwrt-Monitoring/Docker/netify-log.sh  


### Router Setup (Openwrt 21.x)
* Download the shell script to setup the router
  * wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/routersetup.sh
    * nano routersetup.sh
      * replace 10.0.5.5 with your Home Server IP
* sh routersetup.sh
  * Reboot Router

<pre>
The routersetup.sh script will do the following:

Install Nano, netperf (needed for speedtest.sh), openssh-sftp-server,vnstat

Install Prometheus and CollectD

Install iptmon, wrtbwmon and luci-wrtbwmon

Copy custom scripts from this git to /usr/bin/ on the router

Copy custom LUA files from this git to /usr/lib/lua/prometheus-collectors on the router.

Adding new_device.sh script to dhcp dnsmasq

Adding scripts to Crontab

Update prometheus config to 'lan'

Update Collectd Export IP to home server ip address

Add iptmon to your dhcp file under dnsmasq section

Set your lan interface to assign out DNS IP of your home server

restarts services
</pre>


--------

Credit: I have to give credit to Matthew Helmke, I used his blog and grafana dashboard and I added some stuff. I cant say I'm an expert in Grafana or Prometheus (first time using Prom) https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/



