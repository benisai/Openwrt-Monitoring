#!/bin/bash

# Create the parent folder if it doesn't exist
if [ ! -d "$HOME/netify" ]; then
  mkdir "$HOME/netify"
  echo "The 'netify' folder has been created successfully."
else
  echo "The 'netify' folder already exists."
fi

# Create the 'geoip' folder if it doesn't exist
if [ ! -d "$HOME/netify/geoip" ]; then
  mkdir "$HOME/netify/geoip"
  echo "The 'geoip' folder has been created successfully."
else
  echo "The 'geoip' folder already exists."
fi

# Create the 'config' folder if it doesn't exist
if [ ! -d "$HOME/netify/config" ]; then
  mkdir "$HOME/netify/config"
  echo "The 'config' folder has been created successfully."
else
  echo "The 'config' folder already exists."
fi

# Define the file URLs to be copied
file1_url="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/Netify-MySQL-GeoIP.py"
file2_url="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/netify.service"
file3_url="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/requirements.txt"

# Download and copy the files to the netify folder
curl -o "$HOME/netify/Netify-MySQL-GeoIP.py" "$file1_url"
curl -o "$HOME/netify/netify.service" "$file2_url"
curl -o "$HOME/netify/requirements.txt" "$file3_url"

# Replace the USERNAME placeholder with the logged-in user's username
logged_in_user=$(whoami)
sed -i "s|/USERNAME|/home/$logged_in_user|g" "$HOME/netify/netify.service"
sed -i "s|/USERNAME|/home/$logged_in_user|g" "$HOME/netify/netify.service"

# Install MySQL and set the root password
sudo apt-get update
sudo apt-get install -y mysql-server
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '30EiZl893kas';"

# Create a new user for the 'netify' database
sudo mysql -e "CREATE USER 'netify'@'localhost' IDENTIFIED BY 'netify';"
sudo mysql -e "GRANT ALL PRIVILEGES ON netify.* TO 'netify'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Install the required packages using pip
pip3 install -r "$HOME/netify/requirements.txt"

echo "The files have been successfully copied to the 'netify' folder, the USERNAME placeholder has been replaced, the MySQL root password has been set, a new user 'netify' has been created with full access to the 'netify' database, and the required packages have been installed."

# Reload systemd daemon, start the netify service, and display its status
sudo systemctl daemon-reload
sudo systemctl start netify
sudo systemctl status netify
