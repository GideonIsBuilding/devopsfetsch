#!/bin/bash

#--------------------------
# Function to echo in green
#--------------------------
green_echo() {
     echo -e "\e[32m$1\e[0m"
}

#------------------------
# Function to echo in red
#------------------------
red_echo() {
     echo -e "\e[31m$1\e[0m"
}

#---------------------------------
# Function to display help message
#---------------------------------
display_help() {
     clear
     echo "++++++++++++DEVOPSFETCH Manual ++++++++++++"
     echo ""
     echo "NAME"
     echo     "devopsfetch — script that collects and displays system information"
     echo ""
     echo "DESCRIPTION"
     echo     "devopsfetch (pronounced 'devops-fetch') is a DevOps tool that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses."
     echo ""
     echo "Usage: devopsfetch [OPTION]... [ARGUMENT]..."
     echo "Retrieve and display server information."
     echo ""
     echo     "The options are as follows:"

     echo     "-d --docker     List all Docker images and containers."

     echo     "-h --help       Print help."

     echo     "-n --nginx      Display all Nginx domains and their ports."

     echo     "-p --port       Display all active ports and services."

     echo     "-u --users      List all users and their last login times."

     echo     "-t --time       Display activities within a specified time range."
     echo "++++++++++++++++++++++++++++++++++++++++++++++++"
     echo ""
     echo "Examples:"
     echo "  devopsfetch -p                 # List all active ports"
     echo "  devopsfetch -p 80              # Show details for port 80"
     echo "  devopsfetch -d                 # List all Docker images and containers"
     echo "  devopsfetch -d mycontainer     # Show details for 'mycontainer'"
     echo "  devopsfetch -n                 # List all Nginx domains and ports"
     echo "  devopsfetch -n example.com     # Show config for 'example.com'"
     echo "  devopsfetch -u                 # List all users and last login times"
     echo "  devopsfetch -u johndoe         # Show details for user 'johndoe'"
     echo "  devopsfetch -t '2023-01-01 00:00:00' '2023-01-31 23:59:59'"
}

if [ -z "$1" ]; then
     red_echo "Error: No flag provided."
     exit 1
fi

# Define allowed flags
allowed_flags="d h n p u t"

# Check if the first argument is an allowed flag
if [[ ! "$allowed_flags" =~ "$1" ]]; then
     red_echo "Invalid flag. Please enter one of the following flags: d, h, n, p, u, t"
     exit 1
else
     green_echo "Valid flag: $1"
     # You can add further processing for the valid flags here
fi


display_help

dockerImages() {
     echo "Docker Images and Containers:"
     docker ps -a && docker images
     read -rp "Press any key to Continue...."
}

help() {
     echo "Program Usage Intructions:"
     display_help
     read -rp "Press any key to Continue...."
}

nginxDomain() {
     echo "Nginx Domains and Ports:"
     sudo nginx -T | grep "server_name " && grep -r "listen" /etc/nginx | grep -oP "listen\s+\K(\d+)"
     read -rp "Press any key to Continue...."
}

activePort() {
     if [ -z "$1" ]; then
          echo "Active Ports and Services:"
          sudo lsof -i -P -n | grep LISTEN
     else
          echo "Information for port $1:"
          sudo lsof -i ":$1"
          sudo lsof -i -P -n | grep LISTEN | grep "$1"
     fi
}

case "$1" in
     -p|--port)
          display_ports "$2"
          ;;
     -d|--docker)
          display_docker "$2"
          ;;
     -n|--nginx)
          display_nginx "$2"
          ;;
     -u|--users)
          display_users "$2"
          ;;
     -t|--time)
          display_time_range "$2" "$3"
          ;;
     -h|--help)
          display_help
          ;;
     *)
          echo "Invalid option. Use -h or --help for usage information."
          exit 1
          ;;
     esac