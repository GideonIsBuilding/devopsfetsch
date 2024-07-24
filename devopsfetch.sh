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
# Function to display docker images
#---------------------------------
dockerImages() {
     if [ -n "$1" ]; then
          docker inspect "$1"
     else
          docker ps -a
          docker images
     fi
}

#---------------------------------
# Function to display help message
#---------------------------------
showMenu() {
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
     echo "  devopsfetch -d                 # List all Docker images and containers"
     echo "  devopsfetch -d mycontainer     # Show details for 'mycontainer'"
     echo "  devopsfetch -n                 # List all Nginx domains and ports"
     echo "  devopsfetch -n example.com     # Show config for 'example.com'"
     echo "  devopsfetch -p                 # List all active ports"
     echo "  devopsfetch -p 80              # Show details for port 80"
     echo "  devopsfetch -u                 # List all users and last login times"
     echo "  devopsfetch -u johndoe         # Show details for user 'johndoe'"
     echo "  devopsfetch -t '2023-01-01 00:00:00' '2023-01-31 23:59:59'"
}

#---------------------------------
# Function to display domain config
#---------------------------------
nginxDomainConfig() {
     if [ -n "$1" ]; then
          grep -r -A 20 -B 5 "server_name.*$1" /etc/nginx/
     else
          echo "Error: No domain provided."
     fi
     }

#---------------------------------
# Function to display nginx ports
#---------------------------------
nginxDomain() {
     echo -e "DOMAIN\t\t\t\tPORT"
     echo -e "------\t\t\t\t----"
     sudo nginx -T 2>/dev/null | awk '
     /server_name/ { 
          server_name = $2; 
          for (i=3; i<=NF; i++) {
               server_name = server_name " " $i; 
          }
     } 
     /listen/ { 
          listen = $2; 
          gsub(";", "", listen); # Remove semicolon
          if (server_name != "") {
               print server_name "\t" listen;
          }
     }
     ' | column -t
     }

#---------------------------------------------------------
# Function to display active ports or more info about them
#---------------------------------------------------------
activePort() {
     if [ -z "$1" ]; then
          green_echo "Active Ports and Services:"
          sudo lsof -i -P -n | grep LISTEN
     else
          green_echo "Information for port $1:"
          sudo lsof -i ":$1"
     fi
}

#---------------------------------
# Function to display users info
#---------------------------------
displayUsers() {
     if [ -n "$1" ]; then
          green_echo "Information for user $1:"
          id "$1"
          green_echo "Last login:"
          last "$1" | head -n1
     else
          lastlog
     fi
}

#------------------------------------------------------
# Function to display activities within a specific time
#------------------------------------------------------
activitiesTimeRange() {
     if [ -z "$1" ] || [ -z "$2" ]; then
          red_echo "Please provide both start and end times in this format YYYY-MM-DD."
          return 1
     fi
          green_echo "Activities between $1 and $2:"
          journalctl --since "$1" --until "$2"
}

#-------------------------------------
# Main script logic using users' input
#-------------------------------------
case "$1" in
     -p|--port)
          activePort "$2"
          ;;
     -d|--docker)
          dockerImages "$2"
          ;;
     -n|--nginx)
          if [ -n "$2" ]; then
               nginxDomainConfig "$2"
          else
               nginxDomain
          fi
          exit 0
          ;;
     -u|--users)
          displayUsers "$2"
          ;;
     -t|--time)
          activitiesTimeRange "$2" "$3"
          ;;
     -h|--help)
          showMenu
          ;;
     *)
          red_echo "Invalid option. Use -h or --help for usage information."
          exit 1
          ;;
     esac