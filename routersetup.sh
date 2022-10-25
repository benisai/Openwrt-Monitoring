#!/bin/sh

# === Please set the Home server IP ============
HOMESERVER=0.0.0.0

# === Installing CollectD, Prometheus, and IPTMON =============
 echo 'Updating software packages'
 opkg update
 echo 'Installing Nano and CollectD Software on Router'
 opkg install nano collectd collectd-mod-iptables collectd-mod-ping luci-app-statistics 
 echo 'Installing Prometheus on Router'
 opkg install  prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations
 echo 'Installing IPTMON 1.6.1'
 wget https://github.com/oofnikj/iptmon/releases/download/v0.1.6/iptmon_0.1.6-1_all.ipk -O /root/iptmon_0.1.6-1_all.ipk
 opkg install /root/iptmon_0.1.6-1_all.ipk


# === Copying nat_traffic.lua and app-statistics Files from GIT =============
 echo 'Copying nat_traffic.lua from /benisai/Openwrt-Monitoring/nat_traffic.lua'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/nat_traffic.lua -O /usr/lib/lua/prometheus-collectors/nat_traffic.lua
 
echo 'Copying luci_statistics from /benisai/Openwrt-Monitoring/luci_statistics'
wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/luci_statistics -O /etc/config/luci_statistics


# === Setting up app-statistics and prometheus configs =============
 echo 'updating prometheus config from loopback to lan'
 sed -i 's/loopback/lan/g'  /etc/config/prometheus-node-exporter-lua
  
 echo 'updating luci_statistics config from 10.0.5.5 to ${HOMESERVER}'
 sed -i 's/10.0.5.5/${HOMESERVER}/g'  /etc/config/luci_statistics
 
# === Setting Services to enable and restarting Services =============
 echo 'restarting services'
 /etc/init.d/luci_statistics enable
 /etc/init.d/collectd enable
 /etc/init.d/prometheus-node-exporter-lua restart


echo 'You should restart the router now for these changes to take effect...'
