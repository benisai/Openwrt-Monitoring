# Openwrt-Monitoring
Openwrt Monitoring via Grafana.

This project consists of a few applications to help monitor your home router. You will need a decent router (anything from 2-3yrs ago will work) with dual core CPU, with 256mb-512mb of RAM and 128mb nand.
Note: This will only work with Openwrt 21.x (IPTables) NFTables will not be supported. 


A Home Server running Docker to run the following applications (Scroll down for steps). <br/>
```Note:  I provided a Docker-Compose.yml file with all the containers needed for the project```
<br/>

  >Prometheus - Container to scrape and store data.

  >Grafana - Container to display the graphs. (you will need to add your Prometheus location as the data source) 
  
  >Loki + Promtail + Middleware - Containers used to collect and process Netify logs provided created by netify-log.sh

  >AdGuardHome - Container to block Ads/Porn/etc. <br />
  ```Note: you will need to free port 53, see this link "https://www.linuxuprising.com/2020/07/ubuntu-how-to-free-up-port-53-used-by.html"```

  >Prom-Exporters - Container(s) used to export data so prometheus can scrape the data.



On the router, the following software will be installed (Scroll down for routersetup.sh script)

  >Prometheus - main router monitoring (CPU,MEM,etc)

  >Collectd - to monitor ping and export iptmon data 

  >vnstat2 - to monitor monthly WAN Bandwidth usage (12am-Script.sh will check if its the 1st of the month and drop the vnstatdb)

  >iptmon - to monitor per device usage
 
 
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




<br/>

# Installation



Home Server Steps:
You will need a Raspberry Pi or other linux server with Docker and Docker Compose. 

<pre>

Clone this repo to your server. 
:~# gh repo clone benisai/Openwrt-Monitoring

:~# cd Docker

-->NOTE: Make sure to update the prometheus.yml and the netify-log.sh file with your router IP (replace 10.0.5.1 with your Router IP).

Please create Docker Network called Internal
:~# Sudo docker network create internal

:~# Sudo Docker-Compose.yml up -d

This Docker-Compose.yml file will install Grafana/Prometheus/Collectd-Exporter/AdguardHome/AdguardHome-Exporter.

Lastly, we need to create a 'sudo crontab -e' entry for the netify-log.sh script. 
  > sudo chmod +x netify-log.sh
  > sudo crontab -e 
    */1 * * * * /home/USER/Openwrt-Monitoring/Docker/netify-log.sh >> /var/log/crontab.netify.txt 2>&1

Login to grafana, add the prometheus datasource (I have 2 sources, one for OWRT and the other for AdguardHome, we can use the same datasource if you'd like) and Import the dashboard from this GIT Repo. (OpenWRT-Dashboard.json)
If you do not use AdguardHome, just set both sources to the same Prometheus Source)

Note about the Grafana Dashboard:: You'll find two variables at the top. One for iptimon (hostname) and (srcip) for prometheus metrics. Unfortunately Prometheus exporter does not export via hostname only IP address. And iptimon exports as hostname. You can use the DHCP panel to find the corresponding IP address to hostname. 

</pre>



---------------------------------------------------------------
OpenWRT21.x Router Steps: 


<br>

I've created a shell script that can be ran on the router, it will install all the needed software, scripts and custom lua files. 

Before running the shell script, please edit the routersetup.sh file and replace the home server ip variable. My home server is at 10.0.5.5, if you dont replace this ip, it will cause your DNS to stop working and your collectd export settings wont work. 

<pre>
wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/routersetup.sh

nano routersetup.sh -> find 10.0.5.5 and replace that ip with your home-server ip.

sh routersetup.sh

reboot router

</pre>

Note: The New_Device section does not work at the moment.

The routersetup.sh script will do the following:

 >Install Nano, netperf (needed for speedtest.sh), openssh-sftp-server,vnstat

 >Install Prometheus and CollectD
 
 >Install iptmon, wrtbwmon and luci-wrtbwmon
 
 >Copy custom scripts from this git to /usr/bin/ on the router
 
 >Copy custom LUA files from this git to /usr/lib/lua/prometheus-collectors on the router.
 
 >Adding new_device.sh script to dhcp dnsmasq
 
 >Adding scripts to Crontab
 
 >Update prometheus config to 'lan'
 
 >Update Collectd Export IP to home server ip address
 
 >Add iptmon to your dhcp file under dnsmasq section
 
 >Set your lan interface to assign out DNS IP of your home server
 
 >restarts services






---
Credit: I have to give credit to Matthew Helmke, I used his blog and grafana dashboard and I added some stuff. I cant say I'm an expert in Grafana or Prometheus (first time using Prom)
https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/
