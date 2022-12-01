#!/bin/sh

# === Please set the IP address to point to your Home Server (Where Docker is installed) ============
HOMESERVER="10.0.5.5"
echo "Using IP Address: ${HOMESERVER} for HomeServer (where Docker is installed)"

# === Set Custom Alias for clear as cls ============
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/alias.sh
alias cls="clear"
EOF


# === Installing CollectD, Prometheus, and IPTMON. Also Speedtest.sh =============
 echo 'Updating software packages'
 opkg update
 
 echo 'Installing Nano, netperf and sftp-server'
 opkg install nano netperf openssh-sftp-server
 
 echo 'Installing Nano and CollectD Software on Router'
 opkg install collectd collectd-mod-iptables collectd-mod-ping luci-app-statistics collectd-mod-dhcpleases 
 
 echo 'Installing Prometheus on Router'
 opkg install  prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-uci_dhcp_host prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations
 
 echo 'Installing IPTMON 1.6.1'
 wget https://github.com/oofnikj/iptmon/releases/download/v0.1.6/iptmon_0.1.6-1_all.ipk -O /root/iptmon_0.1.6-1_all.ipk
 opkg install /root/iptmon_0.1.6-1_all.ipk
 
 echo 'Installing WrtBWmon'
 wget https://github.com/pyrovski/wrtbwmon/releases/download/0.36/wrtbwmon_0.36_all.ipk
 opkg install /root/wrtbwmon_0.36_all.ipk
 
 ipt=$(uci show dhcp.@dnsmasq[0].dhcpscript | grep "iptmon")
 if [[ -z "$ipt" ]]; then
  echo "Adding iptmon to DHCPScript option"
        uci set dhcp.@dnsmasq[0].dhcpscript=/usr/sbin/iptmon
        uci commit
        echo '/usr/sbin/iptmon init' >> /etc/firewall.user
        elif [[ -n "$ipt" ]]; then
  echo "IPTMon was found, no changes made to DHCP"
 fi

 
 echo 'Copying shell scripts and files from Github/benisai/Openwrt-Monitoring/Router/'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/speedtest.sh -O /usr/bin/speedtest.sh && chmod +x /usr/bin/speedtest.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/15-second-script.sh -O /usr/bin/15-second-script.sh && chmod +x /usr/bin/15-second-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/1-minute-script.sh -O /usr/bin/1-minute-script.sh && chmod +x /usr/bin/1-minute-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/new_device.sh -O /usr/bin/new_device.sh && chmod +x /usr/bin/new_device.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/backup-vnstatDB.sh -O /usr/bin/backup-vnstatDB.sh && chmod +x /usr/bin/backup-vnstatDB.sh
 
 echo 'Copy vnstat backup and wrtbwmon files'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/vnstat_backup -O /etc/init.d/vnstat_backup && chmod +x /etc/init.d/vnstat_backup
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/wrtbwmon -O /usr/sbin/wrtbwmon && chmod +x /usr/sbin/wrtbwmon
 
 #Adding new_device.sh script to dhcp dnsmasq
 echo 'Adding new_device.sh script to dhcp dnsmasq.conf'
 if [[ -z "$new_device.sh" ]]; then
  echo "Adding new_device.sh to DHCPScript option"
        uci set dhcp.@dnsmasq[0].dhcpscript=/usr/sbin/new_device.sh
        uci commit
        elif [[ -n "$new_device.sh" ]]; then
  echo "Script New_Device.sh was found, no changes made to DHCP"
 fi

 #Adding scripts to Crontab
 echo 'Add Scripts to crontab'
 C=$(crontab -l | grep "ready")
 if [[ -z "$C" ]]; then
   echo "Adding Scripts*.sh to crontab"
   crontab -l | { cat; echo "59 * * 12 * /ready"; } | crontab -
   crontab -l | { cat; echo "0 1 * * * /usr/bin/backup-vnstatDB.sh"; } | crontab -
   crontab -l | { cat; echo "0 0 * * * /usr/bin/speedtest.sh"; } | crontab -
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/1-minute-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 15; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 30; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 45; /usr/bin/15-second-script.sh"; } | crontab -
   
   crontab -l | { cat; echo "10 0 * * * rm -rf /tmp/speedtest.out"; } | crontab -
   elif [[ -n "$C" ]]; then
   echo "Keyword (ready) was found in crontab, no changes made"
 fi

 
# === Copying nat_traffic.lua and app-statistics Files from GIT =============
 echo 'Copying nat_traffic.lua from /benisai/Openwrt-Monitoring/nat_traffic.lua'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/nat_traffic.lua -O /usr/lib/lua/prometheus-collectors/nat_traffic.lua
 echo 'Copying luci_statistics from /benisai/Openwrt-Monitoring/luci_statistics'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/luci_statistics -O /etc/config/luci_statistics
 echo 'Copying speedtest.lua from /benisai/Openwrt-Monitoring/Router/speedtest.lua'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/speedtest.lua -O /usr/lib/lua/prometheus-collectors/speedtest.lua
 echo 'Copying wanip.lua from /benisai/Openwrt-Monitoring/Router/wanip.lua'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/wanip.lua -O /usr/lib/lua/prometheus-collectors/wanip.lua
 echo 'Copying packetloss.lua from /benisai/Openwrt-Monitoring/Router/packetloss.lua'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/packetloss.lua -O /usr/lib/lua/prometheus-collectors/packetloss.lua
 
# === Setting up app-statistics and prometheus configs =============
 echo 'updating prometheus config from loopback to lan'
 sed -i 's/loopback/lan/g'  /etc/config/prometheus-node-exporter-lua

# === Updating CollectD export ip ==============
 echo 'updating luci_statistics server export config to ${HOMESERVER}"
 sed -i "s/10.0.5.5/${HOMESERVER}/g"  /etc/config/luci_statistics

# === Setting up DNS ===========
L=$(uci show dhcp.lan.dhcp_option | grep "$HOMESERVER")
 if [[ -z "$L" ]]; then
  echo "Adding $HOMESERVER DNS entry to LAN Interface"
  uci add_list dhcp.lan.dhcp_option="6,${HOMESERVER}"
  uci commit dhcp
 elif [[ -n "$L" ]]; then
  echo "${HOMESERVER} DNS was found, no changes to DNS"
 fi

# === Setting Services to enable and restarting Services =============
 echo 'Enable and Restart services'
 /etc/init.d/cron start
 /etc/init.d/cron enable
 /etc/init.d/wrtbwmon enable
 /etc/init.d/wrtbwmon start
 /etc/init.d/vnstat_backup enable
 /etc/init.d/luci_statistics enable
 /etc/init.d/collectd enable
 /etc/init.d/collectd restart
 /etc/init.d/prometheus-node-exporter-lua restart
 /etc/init.d/dnsmasq restart
 /etc/init.d/firewall restart
 /etc/init.d/cron restart
 

# === 
echo 'You should restart the router now for these changes to take effect...'
