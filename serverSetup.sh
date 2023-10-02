#!/bin/bash

# Determine the currently logged-in user
CURRENT_USER=$(whoami)

# Set the Router IP address
ROUTER_IP="10.0.5.1"

# Check if the ROUTER_IP is set to the default value
if [ "$ROUTER_IP" == "10.0.5.1" ]; then
    read -p "Is 10.0.5.1 the correct Router IP? (Y/n): " correct_ip

    if [[ ! $correct_ip =~ ^[Yy]$ ]]; then
        echo "Please update the script with the correct Router_IP variable and run it again."
        exit 1
    fi
fi


# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed."
    read -p "Do you want to install Docker? (Y/n): " install_docker

    if [[ $install_docker =~ ^[Yy]$ ]]; then
        # Install Docker using the official script
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
    else
        echo "Docker installation aborted. Exiting script."
        exit 1
    fi
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
