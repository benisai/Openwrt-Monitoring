import subprocess
import json
import sqlite3
import requests
import geoip2.database

# Router IP Address
ROUTER_IP = "10.10.10.1"

# SQLite configuration
DB_FILE = "netifydb.db"

# GeoIP database file
GEOIP_DB_FILE = "./geoip/GeoLite2-City.mmdb"

# GeoIP database reader
geoip_reader = geoip2.database.Reader(GEOIP_DB_FILE)

# Prometheus metrics URL
prometheus_url = f"http://{ROUTER_IP}:9100/metrics"
mac_host_mapping_file = "./config/mac_host_mapping.txt"

# Fetch metrics data and generate mac_host_mapping.txt
def generate_mac_host_mapping():
    response = requests.get(prometheus_url)
    data = response.text

    mac_host_mapping = {}
    lines = data.split("\n")
    for line in lines:
        if line.startswith('uci_dhcp_host{'):
            mac_start = line.find('mac="') + len('mac="')
            mac_end = line.find('"', mac_start)
            mac = line[mac_start:mac_end]

            name_start = line.find('name="') + len('name="')
            name_end = line.find('"', name_start)
            name = line[name_start:name_end]

            mac_host_mapping[mac] = name

    with open(mac_host_mapping_file, "w") as file:
        for mac, hostname in mac_host_mapping.items():
            file.write(f"{mac.lower()} {hostname}\n")

# Generate mac_host_mapping.txt
generate_mac_host_mapping()

# Read mac_host_mapping.txt and create mapping dictionary
mac_host_mapping = {}
with open(mac_host_mapping_file, "r") as file:
    lines = file.readlines()
    for line in lines:
        line = line.strip()
        if line:
            mac, hostname = line.split(" ", 1)
            mac_host_mapping[mac] = hostname

# Establish SQLite connection
db = sqlite3.connect(DB_FILE)
cursor = db.cursor()

# Create table if it doesn't exist
create_table_query = """
CREATE TABLE IF NOT EXISTS netify (
    hostname TEXT,
    local_ip TEXT,
    local_mac TEXT,
    local_port INTEGER,
    fqdn TEXT,
    dest_ip TEXT,
    dest_mac TEXT,
    dest_port INTEGER,
    dest_type TEXT,
    detected_protocol_name TEXT,
    first_seen_at INTEGER,
    first_update_at INTEGER,
    vlan_id INTEGER,
    interface TEXT,
    internal INTEGER,
    ip_version INTEGER,
    last_seen_at INTEGER,
    type TEXT,
    dest_country TEXT,
    dest_state TEXT,
    dest_city TEXT
);
"""
cursor.execute(create_table_query)
db.commit()

# Netcat command
netcat_process = subprocess.Popen(
    ["nc", ROUTER_IP, "7150"],
    stdout=subprocess.PIPE,
    universal_newlines=True
)

# Process the data stream
for line in netcat_process.stdout:
    # Filter lines containing "established"
    if "established" in line:
        # Remove unwanted text
        line = line.replace('"established":false,', '')
        line = line.replace('"flow":{', '')
        line = line.replace('0}', '0')

        # Parse JSON
        data = json.loads(line)

        # Extract relevant variables
        detected_protocol_name = data["detected_protocol_name"]
        first_seen_at = data["first_seen_at"]
        first_update_at = data["first_update_at"]
        ip_version = data["ip_version"]
        last_seen_at = data["last_seen_at"]
        local_ip = data["local_ip"]
        local_mac = data["local_mac"]
        local_port = data["local_port"]
        dest_ip = data["other_ip"]
        dest_mac = data["other_mac"]
        dest_port = data["other_port"]
        dest_type = data["other_type"]
        vlan_id = data["vlan_id"]
        interface = data["interface"]
        internal = int(data["internal"])
        type = data["type"]

        # Check if 'host_server_name' exists in the data
        if "host_server_name" in data:
            fqdn = data["host_server_name"]
        else:
            fqdn = "NoFQDN"

        # Check if local_mac exists in mac_host_mapping
        if local_mac in mac_host_mapping:
            hostname = mac_host_mapping[local_mac]
        else:
            hostname = "Unknown"

        # GeoIP lookup for dest_ip
        try:
            geoip_response = geoip_reader.city(dest_ip)
            dest_country = geoip_response.country.name
            dest_state = geoip_response.subdivisions.most_specific.name
            dest_city = geoip_response.city.name
        except geoip2.errors.AddressNotFoundError:
            dest_country = "country_Unknown"
            dest_state = "state_Unknown"
            dest_city = "city_Unknown"

        # Insert values into SQLite table
        sql = "INSERT INTO netify (hostname, local_ip, local_mac, local_port, fqdn, dest_ip, dest_mac, dest_port, dest_type, detected_protocol_name, first_seen_at, first_update_at, vlan_id, interface, internal, ip_version, last_seen_at, type, dest_country, dest_state, dest_city) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        values = (
            hostname, local_ip, local_mac, local_port, fqdn, dest_ip, dest_mac, dest_port, dest_type,
            detected_protocol_name, first_seen_at, first_update_at, vlan_id, interface, internal, ip_version,
            last_seen_at, type, dest_country, dest_state, dest_city
        )

        cursor.execute(sql, values)
        db.commit()

# Close SQLite connection
cursor.close()
db.close()
geoip_reader.close()
