#!/bin/bash

# Determine the currently logged-in user
CURRENT_USER=$(whoami)

# Set the Router IP address
ROUTER_IP="10.0.5.1"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Clone the repository
git clone https://github.com/benisai/Openwrt-Monitoring.git
cd Openwrt-Monitoring/Docker

# Replace the Router IP in prometheus.yml
sed -i "s/10.0.5.1/$ROUTER_IP/g" prometheus.yml

# Replace the Router IP in netify-log.sh
sed -i "s/10.0.5.1/$ROUTER_IP/g" netify-log.sh

# Create a Docker network
sudo docker network create internal

# Start the Docker containers
sudo docker-compose up -d

# Create a Crontab entry
echo "*/1 * * * * /home/$CURRENT_USER/Openwrt-Monitoring/Docker/netify-log.sh >> /var/log/crontab.netify.txt 2>&1" > cronjob.tmp

# Make netify-log.sh executable
sudo chmod +x netify-log.sh

# Edit netify-log.sh
sudo nano netify-log.sh

# Clean up temporary files
rm cronjob.tmp
