# Openwrt-Monitoring
Openwrt Monitoring via Grafana

https://github.com/benisai/Openwrt-Monitoring/blob/main/OpenWRT.PNG

Install Collectd on Openwrt router
opkg update
opkg install luci-app-statistics
opkg install collectd-mod-ethstat collectd-mod-ipstatistics collectd-mod-irq collectd-mod-load collectd-mod-ping collectd-mod-powerdns collectd-mod-sqm collectd-mod-thermal collectd-mod-wireless collectd-mod-iptables

Install IPTMON on OpenWRT
VERSION=0.1.6
wget https://github.com/oofnikj/iptmon/releases/download/v${VERSION}/iptmon_${VERSION}-1_all.ipk -O iptmon_${VERSION}-1_all.ipk
opkg install ./iptmon_${VERSION}-1_all.ipk

Install 
