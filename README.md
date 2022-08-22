# Openwrt-Monitoring
Openwrt Monitoring via Grafana.
This project consists of a few other applications to help. 
Install on Router. You will need a dual core CPU, with 256mb of RAM. 

----

![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard1.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard2.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard3.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard4.PNG)

---------------------------------------------------------------

Install Collectd on Openwrt router
<pre>
opkg update
opkg install collectd collectd-mod-contextswitch collectd-mod-cpu  collectd-mod-dhcpleases /
collectd-mod-disk collectd-mod-dns collectd-mod-ethstat /
collectd-mod-interface collectd-mod-iptables collectd-mod-iwinfo /
collectd-mod-load collectd-mod-memory collectd-mod-network /
collectd-mod-ping collectd-mod-processes collectd-mod-protocols /
collectd-mod-rrdtool collectd-mod-tcpconns collectd-mod-uptime
</pre>


Collectd -- After installing collectd on the router, you will need to configure the plugins such as ping and firewall via luci
* make sure to configure your output, it has to point to your collectd-exporter.

![Collectd firewall](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Collectd-output.PNG)

* Configure CollectD firewall -> statistics -> collectd. (make sure to configure the firewall like shown below). 
![Collectd firewall](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/CollectD1-firewall.PNG)

--------

Prometheus -- Use this guide to install Prometheus on the router (https://grafana.com/blog/2021/02/09/how-i-monitor-my-openwrt-router-with-grafana-cloud-and-prometheus/)

<pre>
opkg install prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic \
prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt \ 
prometheus-node-exporter-lua-uci_dhcp_host prometheus-node-exporter-lua-wifi \
prometheus-node-exporter-lua-wifi_stations collectd-mod-dhcpleases
</pre>

--------

IPTMON.ipk -- Use this guide to install iptmon on the router (https://github.com/oofnikj/iptmon#installation-on-openwrt)
NOTE: If you care about SQM/CAKE/ETC, it will **probably** not play nice with iptmon reporting. 

Install IPTMON on OpenWRT
<pre>
VERSION=0.1.6
wget https://github.com/oofnikj/iptmon/releases/download/v${VERSION}/iptmon_${VERSION}-1_all.ipk -O iptmon_${VERSION}-1_all.ipk
opkg install ./iptmon_${VERSION}-1_all.ipk
</pre>


---------------------------------------------------------------

Docker-Compose.yml

sudo docker-compose up -d

