#!/bin/sh

# === Set REPO the branch =====
BRANCH="collectd"

# === Please set the IP address to point to your Home Server (Where Docker is installed) ============
HOMESERVER="10.0.5.5"
echo "Using IP Address: ${HOMESERVER} for HomeServer (where Docker is installed)"

# === Set Custom Alias for clear as cls ============
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/alias.sh
alias cls="clear"
EOF


# === Update repo =============
 echo 'Updating software packages'
 opkg update
 
# List of software to check and install
software="luci-lib-jsonc netperf openssh-sftp-server vnstat2 vnstati2 luci-app-vnstat2 netifyd collectd collectd-mod-iptables collectd-mod-ping luci-app-statistics collectd-mod-dhcpleases prometheus prometheus-node-exporter-lua prometheus-node-exporter-lua-nat_traffic prometheus-node-exporter-lua-openwrt prometheus-node-exporter-lua-uci_dhcp_host prometheus-node-exporter-lua-wifi prometheus-node-exporter-lua-wifi_stations"


# Loop through the list of software
for s in $software
do
  # Check if the software is installed
  opkg list-installed | grep -q "^$s -"
  if [ $? -ne 0 ]
  then
    # If not installed, install it
    echo "$s is not installed. Installing..."
    opkg update
    opkg install $s
    echo "$s installation complete."
  else
    # If installed, print a message
    echo "$s is already installed."
  fi
done


# === Creating DIRs for nlbw2collectd === 
echo 'Creating DIRs for nlbw2collectd' 
# Create /etc/collectd/conf.d if it doesn't exist
if [ ! -d "/etc/collectd/conf.d" ]; then
    echo "Creating directory: /etc/collectd/conf.d"
    mkdir -p "/etc/collectd/conf.d"
else
    echo "Directory already exists: /etc/collectd/conf.d"
fi

# Create /usr/share/collectd-mod-lua/ if it doesn't exist
if [ ! -d "/usr/share/collectd-mod-lua/" ]; then
    echo "Creating directory: /usr/share/collectd-mod-lua/"
    mkdir -p "/usr/share/collectd-mod-lua/"
else
    echo "Directory already exists: /usr/share/collectd-mod-lua/"
fi
 

#======= Copy config / lua files for nlbw2collectd ===============
echo 'Installing nlbw2collectd from GitHub'
wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/collectd/Router/nlbw2collectd/lua.conf -O /etc/collectd/conf.d/lua.conf
wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/collectd/Router/nlbw2collectd/nlbw2collectd.lua -O /usr/share/collectd-mod-lua/nlbw2collectd.lua

 

#Changing vnstat backup location to SD Card.
dt=$(date '+%d%m%Y%H%M%S');
DatabaseDir "/var/lib/vnstat"
DIR=/tmp/mountd/disk1_part1
if [[ -d "$DIR" ]]; then
    echo "$DIR directory exists."
    echo "Backing up /etc/vnstat.conf.$dt"
    cp /etc/vnstat.conf /etc/vnstat.conf.$dt
    sed -i 's/;DatabaseDir /DatabaseDir /g' /etc/vnstat.conf
    sed -i 's,/var/lib/vnstat,/tmp/mountd/disk1_part1/vnstat,g' /etc/vnstat.conf
    #Change VNStatDB save time from 5 mins to 1 min
    sed -i 's/;SaveInterval 5 /;SaveInterval 1 /g' /etc/vnstat.conf
    else
  echo "$DIR directory does not exist."
fi

 
 
 # echo 'Installing WrtBWmon'
 # wget https://github.com/pyrovski/wrtbwmon/releases/download/0.36/wrtbwmon_0.36_all.ipk -O /root/wrtbwmon_0.36_all.ipk
 # wget https://github.com/Kiougar/luci-wrtbwmon/releases/download/v0.8.3/luci-wrtbwmon_v0.8.3_all.ipk -O /root/luci-wrtbwmon_v0.8.3_all.ipk
 # opkg install /root/wrtbwmon_0.36_all.ipk
 # opkg install /root/luci-wrtbwmon_v0.8.3_all.ipk
 

 #Copying scripts and lua files to router
 echo 'Copying shell scripts and files from Github to Router'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/speedtest.sh -O /usr/bin/speedtest.sh && chmod +x /usr/bin/speedtest.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/15-second-script.sh -O /usr/bin/15-second-script.sh && chmod +x /usr/bin/15-second-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/1-minute-script.sh -O /usr/bin/1-minute-script.sh && chmod +x /usr/bin/1-minute-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/1-hour-script.sh -O /usr/bin/1-hour-script.sh && chmod +x /usr/bin/1-hour-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/5-minute-script.sh -O /usr/bin/5-minute-script.sh && chmod +x /usr/bin/5-minute-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/12am-script.sh -O /usr/bin/12am-script.sh && chmod +x /usr/bin/12am-script.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/99-new-device -O /etc/hotplug.d/dhcp/99-new-device 
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/device-status-ping.sh -O /usr/bin/device-status-ping.sh && chmod +x /usr/bin/device-status-ping.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/packet-loss.sh -O /usr/bin/packet-loss.sh && chmod +x /usr/bin/packet-loss.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/new_device.sh -O /usr/bin/new_device.sh && chmod +x /usr/bin/new_device.sh
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/scripts/internet-outage.sh -O /usr/bin/internet-outage.sh && chmod +x /usr/bin/internet-outage.sh


 echo 'Copying custom LUA Files from GIT to router'
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/nat_traffic.lua -O /usr/lib/lua/prometheus-collectors/nat_traffic.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/speedtest.lua -O /usr/lib/lua/prometheus-collectors/speedtest.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/wanip.lua -O /usr/lib/lua/prometheus-collectors/wanip.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/packetloss.lua -O /usr/lib/lua/prometheus-collectors/packetloss.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/new_device.lua -O /usr/lib/lua/prometheus-collectors/new_device.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/vnstatmonth.lua -O /usr/lib/lua/prometheus-collectors/vnstatmonth.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/device-status.lua -O /usr/lib/lua/prometheus-collectors/device-status.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/gl-router-temp.lua -O /usr/lib/lua/prometheus-collectors/gl-router-temp.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/internet-outage.lua -O /usr/lib/lua/prometheus-collectors/internet-outage.lua
 wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/dnsmasq.lua -O /usr/lib/lua/prometheus-collectors/dnsmasq.lua
 
 #echo 'Copying Extra files'
 #wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/vnstat_backup -O /etc/init.d/vnstat_backup && chmod +x /etc/init.d/vnstat_backup
 #wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/wrtbwmon -O /usr/sbin/wrtbwmon && chmod +x /usr/sbin/wrtbwmon
 #wget https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Router/lua/luci_statistics -O /etc/config/luci_statistics

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
   crontab -l | { cat; echo "0 * * * * /usr/bin/1-hour-script.sh"; } | crontab -
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/1-minute-script.sh"; } | crontab -
   crontab -l | { cat; echo "*/5 * * * * /usr/bin/5-minute-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 15; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 30; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "* * * * * sleep 45; /usr/bin/15-second-script.sh"; } | crontab -
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/device-status-ping.sh"; } | crontab -  
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/new_device.sh"; } | crontab - 
   crontab -l | { cat; echo "*/1 * * * * /usr/bin/packet-loss.sh"; } | crontab - 
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
#L=$(uci show dhcp.lan.dhcp_option | grep "$HOMESERVER")
# if [[ -z "$L" ]]; then
#  echo "Adding $HOMESERVER DNS entry to LAN Interface"
#  uci add_list dhcp.lan.dhcp_option="6,${HOMESERVER}"
#  uci commit dhcp
# elif [[ -n "$L" ]]; then
#  echo "${HOMESERVER} DNS was found, no changes to DNS"
# fi

# === Setting Services to enable and restarting Services =============
 echo 'Enable and Restart services'
 /etc/init.d/cron start
 /etc/init.d/cron enable
 # /etc/init.d/wrtbwmon enable
 # /etc/init.d/wrtbwmon start
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
