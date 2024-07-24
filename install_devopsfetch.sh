#!/bin/bash

#--------------------------
# Function to echo in green
#--------------------------
green_echo() {
     echo -e "\e[32m$1\e[0m"
}

#-------------------------------
# Check if script is run as root
#-------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

#------------------------------------------
# Copy devopsfetch script to /usr/local/bin
#------------------------------------------
cp devopsfetch.sh /usr/local/bin/
chmod +x /usr/local/bin/devopsfetch.sh

#----------------------------
# Create systemd service file
#----------------------------
cat << EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -t \$(date -d '1 hour ago' +'%Y-%m-%d %H:%M:%S') \$(date +'%Y-%m-%d %H:%M:%S')
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

#----------------------------------
# Create log rotation configuration
#----------------------------------
cat << EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

#---------------------------------------------
# Reload systemd, enable and start the service
#---------------------------------------------
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

green_echo "DevOpsFetch has been installed and service started."
green_echo "Logs are stored in /var/log/devopsfetch.log"
green_echo "Use 'devopsfetch -h' for usage instructions."