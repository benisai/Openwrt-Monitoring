# Openwrt-Monitoring
Openwrt Monitoring via Grafana
This project consists of a few other applications to help. 
Install on Router. You will need a dual core CPU, with 256mb of RAM
IPTMON.ipk
Prometheus
Collectd

----

Install Grafana,Prometheus,Collectd-Exporter via Docker-Compose.yml



----

![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard1.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard2.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard3.PNG)
![Grafana Dashboard](https://github.com/benisai/Openwrt-Monitoring/blob/main/screenshots/Dashboard4.PNG)

---------------------------------------------------------------

Install Collectd on Openwrt router
opkg update
opkg install collectd collectd-mod-contextswitch collectd-mod-cpu  collectd-mod-dhcpleases /
collectd-mod-disk collectd-mod-dns collectd-mod-ethstat /
collectd-mod-interface collectd-mod-iptables collectd-mod-iwinfo /
collectd-mod-load collectd-mod-memory collectd-mod-network /
collectd-mod-ping collectd-mod-processes collectd-mod-protocols /
collectd-mod-rrdtool collectd-mod-tcpconns collectd-mod-uptime

opkg install prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic \
prometheus-node-exporter-lua-netstat prometheus-node-exporter-lua-openwrt \ 
prometheus-node-exporter-lua-uci_dhcp_host prometheus-node-exporter-lua-wifi \
prometheus-node-exporter-lua-wifi_stations collectd-mod-dhcpleases

Install IPTMON on OpenWRT
VERSION=0.1.6
wget https://github.com/oofnikj/iptmon/releases/download/v${VERSION}/iptmon_${VERSION}-1_all.ipk -O iptmon_${VERSION}-1_all.ipk
opkg install ./iptmon_${VERSION}-1_all.ipk

---------------------------------------------------------------

Docker-Compose.yml

