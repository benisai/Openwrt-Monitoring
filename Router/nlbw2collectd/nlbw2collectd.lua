-- Sourced from on 12/29/24 = https://raw.githubusercontent.com/mstojek/nlbw2collectd/refs/heads/main/nlbw2collectd.lua

require "luci.jsonc"
--require "luci.sys"
--require "luci.util"
local io = require "io"

local HOSTNAME = '' -- leave empty if you track statistics for local system, change when you really know that you want different hostname to be used
local PLUGIN="iptables"
local PLUGIN_INSTANCE_RX="mangle-nlbwmon_rx" -- change to "mangle-iptmon_rx" to have full compliance with iptmon
local PLUGIN_INSTANCE_TX="mangle-nlbwmon_tx" -- change to "mangle-iptmon_tx" to have full compliance with iptmon
local TYPE_BYTES="ipt_bytes"
local TYPE_PACKETS="ipt_packets"
local TYPE_INSTANCE_PREFIX_RX="rx_"
local TYPE_INSTANCE_PREFIX_TX="tx_"

local function isempty(s)
  return s == nil or s == ''
end

local function exec(command)
	local pp   = io.popen(command)
	local data = pp:read("*a")
	pp:close()

	return data
end

local function lookup(ip)
    local client

    -- First check the lease file for host name
--    local lease_file=luci.sys.exec("uci get dhcp.@dnsmasq[0].leasefile")
    local lease_file=exec("uci get dhcp.@dnsmasq[0].leasefile")
    lease_file = lease_file:gsub('[%c]', '')
    command = "grep \"\\b" .. ip .. "\\b\" " .. lease_file .. " | awk '{print $4}'"
--    client=luci.sys.exec(command)
    client=exec(command)
    client = client:gsub('[%c]', '')

    if isempty(client) then
        -- Try with nslookup then
        command = "nslookup " .. ip .. " | grep 'name = ' | sed -E 's/^.*name = ([a-zA-Z0-9-]+).*$/\\1/'"
--        client = luci.sys.exec(command)
        client=exec(command)
        client = client:gsub('[%c]', '')
    end


    if isempty(client) then
        client = ip
    end

    if client == '*' then
        client = ip
    end

    return client
end


function read()
    --collectd.log_info("read function called")
--    local json = luci.sys.exec("/usr/sbin/nlbw -c json -g ip")
    local json = exec("/usr/sbin/nlbw -c json -g ip")
    --collectd.log_info("exec function called")
    local pjson = luci.jsonc.parse(json) 
    --collectd.log_info("Json: " .. json)


    for index, value in ipairs(pjson.data) do
    
    local client = ""
    local ip = value[1]
    --command = "nslookup " .. ip .. " | grep 'name = ' | sed -E 's/^.*name = ([a-zA-Z0-9-]+).*$/\\1/'"
    --local client = exec(command)
    local tx_bytes = value[3]
    local tx_packets = value[4]
    local rx_bytes = value[5]
    local rx_packets = value[6]
    local tx_bytes_modulo = tx_bytes % 2147483647 --workaround since we can not report to collectd more than 32bit integer
    local rx_bytes_modulo = rx_bytes % 2147483647 --workaround since we can not report to collectd more than 32bit integer


    client = lookup(ip)

    --collectd.log_info("ip: " .. ip .. " , client: " .. client)

        tx_b = {
            host = HOSTNAME,
            plugin = PLUGIN,
            plugin_instance = PLUGIN_INSTANCE_TX,
            type = TYPE_BYTES,
            type_instance =  TYPE_INSTANCE_PREFIX_TX .. client, 
            values = {tx_bytes_modulo},
        }
        collectd.dispatch_values(tx_b)

        rx_b = {
            host = HOSTNAME,
            plugin = PLUGIN,
            plugin_instance = PLUGIN_INSTANCE_RX,
            type = TYPE_BYTES,
            type_instance =  TYPE_INSTANCE_PREFIX_RX .. client,
            values = {rx_bytes_modulo},
        }
        collectd.dispatch_values(rx_b)



        tx_p = {
            host = HOSTNAME,
            plugin = PLUGIN,
            plugin_instance = PLUGIN_INSTANCE_TX,
            type = TYPE_PACKETS,
            type_instance =  TYPE_INSTANCE_PREFIX_TX .. client,
            values = {tx_packets},
        }
        collectd.dispatch_values(tx_p)

        rx_p = {
            host = HOSTNAME,
            plugin = PLUGIN,
            plugin_instance = PLUGIN_INSTANCE_RX,
            type = TYPE_PACKETS,
            type_instance =  TYPE_INSTANCE_PREFIX_RX .. client,
            values = {rx_packets},
        }
        collectd.dispatch_values(rx_p)


    end

    return 0
end

collectd.register_read(read)     -- pass function as variable
