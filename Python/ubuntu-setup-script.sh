#!/bin/bash

# MySQL variables
mysql_user="netify"
mysql_password="netify"
mysql_root_password="30EiZl893kas"
mysql_database="netifyDB"

# Create the parent folder if it doesn't exist
if [ ! -d "$HOME/netify" ]; then
  mkdir "$HOME/netify"
  echo "The 'netify' folder has been created successfully."
else
  echo "The 'netify' folder already exists."
fi

# Create the 'files' folder if it doesn't exist
if [ ! -d "$HOME/netify/files" ]; then
  mkdir "$HOME/netify/files"
  echo "The 'files' folder has been created successfully."
else
  echo "The 'files' folder already exists."
fi


# Define the file URLs to be copied
netify_py="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/netify.py"
netify_service="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/netify.service"
requirements="https://raw.githubusercontent.com/benisai/Openwrt-Monitoring/main/Python/requirements.txt"

# Download and copy the files to the netify folder
curl -o "$HOME/netify/netify.py" "$netify_py"
curl -o "/etc/systemd/system/netify.service" "$netify_service"
curl -o "$HOME/netify/requirements.txt" "$requirements"

# Replace the USERNAME placeholder with the logged-in user's username
logged_in_user=$(whoami)
sed -i "s|/USERNAME|/home/$logged_in_user|g" "/etc/systemd/system/netify.service"

# Install MySQL and set the root password
sudo apt-get update
sudo apt-get install -y pip
sudo apt-get install -y mysql-server
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysql_root_password';"

# Create a new user for the specified database
sudo mysql -e "CREATE USER '$mysql_user'@'localhost' IDENTIFIED BY '$mysql_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Install the required packages using pip
pip3 install -r "$HOME/netify/requirements.txt"

echo "The files have been successfully copied to the 'netify' folder, the USERNAME placeholder has been replaced."
echo "The MySQL root password has been set, a new user '$mysql_user' has been created with full access to the '$mysql_database' database" 
echo "The required packages have been installed."


# Add service to crontab to ensure its running
cron_entry="*/1 * * * * sudo systemctl start netify > /var/log/netify.service.log"
# Replace the above line with your desired cron job entry, specifying the path to your shell script.
(crontab -l ; echo "$cron_entry") | crontab -
# Appends the new cron job entry to the existing crontab file.
echo "Cron job added successfully."

# Reload systemd daemon, start the netify service, and display its status
sudo systemctl daemon-reload
sudo systemctl enable myscript
sudo systemctl start netify
sudo systemctl status netify
