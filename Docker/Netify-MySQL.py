import subprocess
import json
import mysql.connector
import requests
import geoip2.database

# MySQL configuration
DB_HOST = "10.0.5.236"
DB_USER = "openwalla"
DB_PASSWORD = "openwalla"
DB_NAME = "openwalla"

# GeoIP database file
GEOIP_DB_FILE = "GeoLite2-City.mmdb"

# Router IP and Prometheus metrics URL
ROUTER_IP = "10.0.5.1"
prometheus_url = f"http://{ROUTER_IP}:9100/metrics"
mac_host_mapping_file = "mac_host_mapping.txt"

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

# Establish MySQL connection
db = mysql.connector.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD
)
cursor = db.cursor()

# Create database if it doesn't exist
cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
db.commit()

# Switch to the specified database
cursor.execute(f"USE {DB_NAME}")

# Create table if it doesn't exist
create_table_query = """
CREATE TABLE IF NOT EXISTS netify (
    hostname VARCHAR(255),
    local_ip VARCHAR(255),
    local_mac VARCHAR(255),
    local_port INT,
    fqdn VARCHAR(255),
    dest_ip VARCHAR(255),
    dest_mac VARCHAR(255),
    dest_port INT,
    dest_type VARCHAR(255),
    detected_protocol_name VARCHAR(255),
    first_seen_at BIGINT,
    first_update_at BIGINT,
    vlan_id INT,
    interface VARCHAR(255),
    internal BOOL,
    ip_version INT,
    last_seen_at BIGINT,
    type VARCHAR(255),
    dest_country VARCHAR(255),
    dest_state VARCHAR(255),
    dest_city VARCHAR(255)
);
"""
cursor.execute(create_table_query)
db.commit()

# GeoIP reader
geoip_reader = geoip2.database.Reader(GEOIP_DB_FILE)

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
        internal = data["internal"]
        type = data["type"]

        # Check if 'host_server_name' exists in the data
        if "host_server_name" in data:
            fqdn = data["host_server_name"]
        else:
            fqdn = "None"

        # Check if local_mac exists in mac_host_mapping
        if local_mac in mac_host_mapping:
            hostname = mac_host_mapping[local_mac]
        else:
            hostname = "Unknown"

        # GeoIP lookup
        try:
            response = geoip_reader.city(dest_ip)
            dest_country = response.country.name
            dest_state = response.subdivisions.most_specific.name
            dest_city = response.city.name
        except geoip2.errors.AddressNotFoundError:
            dest_country = "Unknown"
            dest_state = "Unknown"
            dest_city = "Unknown"

        # Insert values into MySQL table
        sql = "INSERT INTO netify (hostname, local_ip, local_mac, local_port, fqdn, dest_ip, dest_mac, dest_port, dest_type, detected_protocol_name, first_seen_at, first_update_at, vlan_id, interface, internal, ip_version, last_seen_at, type, dest_country, dest_state, dest_city) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        values = (
            hostname, local_ip, local_mac, local_port, fqdn, dest_ip, dest_mac, dest_port, dest_type,
            detected_protocol_name, first_seen_at, first_update_at, vlan_id, interface, internal,
            ip_version, last_seen_at, type, dest_country, dest_state, dest_city
        )

        cursor.execute(sql, values)
        db.commit()

# Close MySQL connection
cursor.close()
db.close()
  
