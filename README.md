# Openwrt-Monitoring
Openwrt Monitoring via Grafana.
This project consists of a few applications to help monitor your home router. You will need a decent router (anything from 2-3yrs ago will work) with dual core CPU, with 256mb-512mb of RAM and 128mb nand.
Note: This will only work with Openwrt 21.x (IPTables) NFTables will not be supported, 

You will also need a Home Server running Docker to run Prometheus,Grafana, and some Exporters. 

Note about the Grafana Dashboard:: You'll find two variables at the top. One for iptimon (hostname) and (srcip) for prometheus metrics. Unfortunately Prometheus exporter does not export via hostname only IP address. And iptimon exports as hostname. You can use the DHCP panel to find the corresponding IP address to hostname. 


Credit: I have to give credit to Matthew Helmke, I used his blog and grafana dashboard and I added some stuff. I cant say I'm an expert in Grafana or Prometheus (first time using Prom)
https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/

----

![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard1.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard2.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard3.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard4.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard5.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard6.PNG)

---------------------------------------------------------------
# Router Steps: 
*This section will cover the openwrt Router config

I've created a shell script that can be ran on the router, it will install all the needed software, scripts and custom lua files. Before running the shell script, please edit the routersetup.sh file and replace the home server ip variable. My home server is at 10.0.5.5, if you dont replace this ip, it will cause your DNS to stop working and your collectd export settings wont work. 
Note: The New_Device section does not work at the moment.

SSH to your router and run
wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/routersetup.sh

sh routersetup.sh


---------------------------------------------------------------
# Home Server Steps:

<pre>
You will need a Raspberry Pi or other linux server with Docker and Docker Compose. 
Clone this repo to your server. 
make sure to update the prometheus.yml file with your server IP and router IP.
run 'Sudo Docker-Compose.yml up -d'
This will install Grafana/Prometheus/Collectd-Exporter/AdguardHome/AdguardHome-Exporter.

Login to grafana and Import the dashboard. (OpenWRT-Dashboard.v2.json)
</pre>
