from datetime import datetime
import subprocess
import json
import mysql.connector
import requests
import geoip2.database
import tarfile
import os
import time


# Router IP Address
ROUTER_IP = "10.0.5.1"

# MySQL configuration
DB_HOST = "10.0.5.236"
DB_USER = "netify"
DB_PASSWORD = "netify"
DB_NAME = "netifyDB"
DB_TABLE = "netify"


# GeoIP database file and license
DOWNLOAD_NEW_DB = "yes"  # Set to "yes" to download the new database, set to "no" to skip DB download
license_key = "YOUR-KEY"
database_type = "GeoLite2-City"
download_url = f"https://download.maxmind.com/app/geoip_download?edition_id={database_type}&license_key={license_key}&suffix=tar.gz"
output_folder = "files"
GEOIP_DB_FILE = "./files/GeoLite2-City.mmdb"

if DOWNLOAD_NEW_DB == "yes":
    # Send a GET request to the download URL
    response = requests.get(download_url, stream=True)

    # Check if the request was successful
    if response.status_code == 200:
        # Extract the filename from the response headers
        content_disposition = response.headers.get("content-disposition")
        filename = content_disposition.split("filename=")[1].strip('\"')

        # Create the output folder if it doesn't exist
        if not os.path.exists(output_folder):
            os.makedirs(output_folder)

        # Open a file for writing in binary mode
        with open(filename, "wb") as f:
            # Iterate over the response content in chunks and write to file
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        # Extract only the GeoLite2-City.mmdb file to the output folder
        with tarfile.open(filename, "r:gz") as tar:
            for member in tar.getmembers():
                if member.name.endswith("GeoLite2-City.mmdb"):
                    member.name = os.path.basename(member.name)
                    tar.extract(member, path=output_folder)

        print(f"Download and extraction complete. Database saved to {output_folder}/GeoLite2-City.mmdb")

        # Delete the .tar.gz file
        os.remove(filename)

        print(f"Deleted {filename} file.")
    else:
        print("Failed to download the database. Please check your license key.")
else:
    print("Skipping database download.")

# GeoIP database reader
geoip_reader = geoip2.database.Reader(GEOIP_DB_FILE)

# Prometheus metrics URL
prometheus_url = f"http://{ROUTER_IP}:9100/metrics"
mac_host_mapping_file = "./files/mac_host_mapping.txt"

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

            ip_start = line.find('ip="') + len('ip="')
            ip_end = line.find('"', ip_start)
            ip = line[ip_start:ip_end]

            mac_host_mapping[mac] = (name, ip)

    with open(mac_host_mapping_file, "w") as file:
        for mac, (hostname, ip) in mac_host_mapping.items():
            file.write(f"{mac.lower()} {hostname} {ip}\n")


# Generate mac_host_mapping.txt
generate_mac_host_mapping()

# Read mac_host_mapping.txt and create mapping dictionary
mac_host_mapping = {}
with open(mac_host_mapping_file, "r") as file:
    lines = file.readlines()
    for line in lines:
        line = line.strip()
        if line:
            mac, hostname, ip = line.split(" ", 2)
            mac_host_mapping[mac] = (hostname, ip)

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
    timeinsert VARCHAR(255),
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
            fqdn = "NoFQDN"
        # Check if local_mac exists in mac_host_mapping
        if local_mac in mac_host_mapping:
            hostname, _ = mac_host_mapping[local_mac]
        else:
            hostname = "Unknown"

        # Retrieve location information using GeoIP
        try:
            response = geoip_reader.city(dest_ip)
            dest_country = response.country.name
            dest_state = response.subdivisions.most_specific.name
            dest_city = response.city.name
        except geoip2.errors.AddressNotFoundError:
            dest_country = "Unknown"
            dest_state = "Unknown"
            dest_city = "Unknown"

        # Get current timestamp
        time_insert = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # SQL query to insert data into the table
        insert_query = f"""
        INSERT INTO {DB_TABLE} (
            timeinsert, hostname, local_ip, local_mac, local_port, fqdn, dest_ip, dest_mac, dest_port, dest_type,
            detected_protocol_name, first_seen_at, first_update_at, vlan_id, interface, internal, ip_version,
            last_seen_at, type, dest_country, dest_state, dest_city
        ) VALUES (
            '{time_insert}', '{hostname}', '{local_ip}', '{local_mac}', {local_port}, '{fqdn}', '{dest_ip}',
            '{dest_mac}', {dest_port}, '{dest_type}', '{detected_protocol_name}', {first_seen_at}, {first_update_at},
            {vlan_id}, '{interface}', {internal}, {ip_version}, {last_seen_at}, '{type}', '{dest_country}',
            '{dest_state}', '{dest_city}'
        );
        """

        # Execute the SQL query
        cursor.execute(insert_query)
        db.commit()

# Close the GeoIP database reader
geoip_reader.close()

# Close MySQL cursor and connection
cursor.close()
db.close()
