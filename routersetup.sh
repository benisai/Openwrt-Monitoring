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
 
 echo 'Installing Nano, netperf and sftp-server and vnstat'
 opkg install nano netperf openssh-sftp-server vnstat2 vnstati2 luci-app-vnstat2
 
 echo 'Installing CollectD Software on Router'
 opkg install collectd collectd-mod-iptables collectd-mod-ping luci-app-statistics collectd-mod-dhcpleases 
 
 echo 'Installing Prometheus on Router'
 opkg install  prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-uci_dhcp_host prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations
 
 echo 'Installing IPTMON 1.6.1'
 wget https://github.com/oofnikj/iptmon/releases/download/v0.1.6/iptmon_0.1.6-1_all.ipk -O /root/iptmon_0.1.6-1_all.ipk
 opkg install /root/iptmon_0.1.6-1_all.ipk
 
  ipt=$(uci show dhcp.@dnsmasq[0].dhcpscript | grep "iptmon")
 if [[ -z "$ipt" ]]; then
  echo "Adding iptmon to DHCPScript option"
        uci set dhcp.@dnsmasq[0].dhcpscript=/usr/sbin/iptmon
        uci commit
        #echo '/usr/sbin/iptmon init' >> /etc/firewall.user
        elif [[ -n "$ipt" ]]; then
  echo "IPTMon was found, no changes made to DHCP"
 fi
 
#Changing vnstat backup location to SD Card. 
#cat << "EOF" >> /etc/vnstat.conf
#DatabaseDir "/tmp/mountd/disk1_part1/vnstat"
#EOF
 
 
 echo 'Installing WrtBWmon'
 wget https://github.com/pyrovski/wrtbwmon/releases/download/0.36/wrtbwmon_0.36_all.ipk
 wget https://github.com/Kiougar/luci-wrtbwmon/releases/download/v0.8.3/luci-wrtbwmon_v0.8.3_all.ipk
 opkg install /root/wrtbwmon_0.36_all.ipk
 opkg install /root/luci-wrtbwmon_v0.8.3_all.ipk
 

 #Copying scripts and lua files to router
 echo 'Copying shell scripts and files from Github to Router'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/speedtest.sh -O /usr/bin/speedtest.sh && chmod +x /usr/bin/speedtest.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/15-second-script.sh -O /usr/bin/15-second-script.sh && chmod +x /usr/bin/15-second-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/1-minute-script.sh -O /usr/bin/1-minute-script.sh && chmod +x /usr/bin/1-minute-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/12am-script.sh -O /usr/bin/12am-script.sh && chmod +x /usr/bin/12am-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/99-new-device -O /etc/hotplug.d/dhcp/99-new-device 
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/device-status-ping.sh -O /usr/bin/device-status-ping.sh && chmod +x /usr/bin/device-status-ping.sh

 echo 'Copying custom LUA Files from GIT to router'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/nat_traffic.lua -O /usr/lib/lua/prometheus-collectors/nat_traffic.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/luci_statistics -O /etc/config/luci_statistics
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/speedtest.lua -O /usr/lib/lua/prometheus-collectors/speedtest.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/wanip.lua -O /usr/lib/lua/prometheus-collectors/wanip.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/packetloss.lua -O /usr/lib/lua/prometheus-collectors/packetloss.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/new_device.lua -O /usr/lib/lua/prometheus-collectors/new_device.lua 
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/device_status.lua -O /usr/lib/lua/prometheus-collectors/device_status.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/vnstatmonth.lua -O /usr/lib/lua/prometheus-collectors/vnstatmonth.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/device-ping-status.lua -O /usr/lib/lua/prometheus-collectors/device-ping-status.lua
 #echo 'Copying Extra files'
 #wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/vnstat_backup -O /etc/init.d/vnstat_backup && chmod +x /etc/init.d/vnstat_backup
 #wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/wrtbwmon -O /usr/sbin/wrtbwmon && chmod +x /usr/sbin/wrtbwmon


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
   crontab -l | { cat; echo "0 */8 * * * /usr/bin/speedtest.sh"; } | crontab -
   crontab -l | { cat; echo "10 6 * * * rm -rf /tmp/speedtest.out"; } | crontab -
   crontab -l | { cat; echo "1 0 * * * /usr/bin/12am-script.sh"; } | crontab -
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/1-minute-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 15; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 30; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 45; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/device-status-ping.sh"; } | crontab -  
   elif [[ -n "$C" ]]; then
   echo "Keyword (ready) was found in crontab, no changes made"
 fi

 
# === Setting up app-statistics and prometheus configs =============
 echo 'updating prometheus config from loopback to lan'
 sed -i 's/loopback/lan/g'  /etc/config/prometheus-node-exporter-lua

# === Updating CollectD export ip ==============
 echo 'updating luci_statistics server export config to ${HOMESERVER}'
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
 #/etc/init.d/vnstat_backup enable
 /etc/init.d/vnstat restart
 /etc/init.d/luci_statistics enable
 /etc/init.d/collectd enable
 /etc/init.d/collectd restart
 /etc/init.d/prometheus-node-exporter-lua restart
 /etc/init.d/dnsmasq restart
 /etc/init.d/firewall restart
 /etc/init.d/cron restart
 

# === 
echo 'You should restart the router now for these changes to take effect...'
