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
        green_echo "Docker Containers:"
        printf "+------------------------+---------------------------------+--------+----------------+\n"
        printf "| %-22s | %-31s | %-6s | %-14s |\n" "CONTAINER ID" "IMAGE" "STATUS" "PORTS"
        printf "+------------------------+---------------------------------+--------+----------------+\n"
        docker ps -a --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | awk '{
            printf "| %-22s | %-31s | %-6s | %-14s |\n", substr($1, 1, 12), $2, $3, $4
        }'
        printf "+------------------------+---------------------------------+--------+----------------+\n"

        green_echo "\nDocker Images:"
        printf "+---------------------------+------------+--------------+------------+\n"
        printf "| %-25s | %-10s | %-12s | %-10s |\n" "REPOSITORY" "TAG" "IMAGE ID" "SIZE"
        printf "+---------------------------+------------+--------------+------------+\n"
        docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" | awk '{
            printf "| %-25s | %-10s | %-12s | %-10s |\n", $1, $2, substr($3, 1, 12), $4
        }'
        printf "+---------------------------+------------+--------------+------------+\n"
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
    green_echo "Nginx Domains and Ports:"
    printf "+--------------------------------+------------+\n"
    printf "| %-30s | %-10s |\n" "DOMAIN" "PORT"
    printf "+--------------------------------+------------+\n"
    sudo nginx -T 2>/dev/null | awk '
    /server_name/ { 
        server_name = $2; 
        for (i=3; i<=NF; i++) {
            server_name = server_name " " $i; 
        }
    } 
    /listen/ { 
        listen = $2; 
        gsub(";", "", listen);
        if (server_name != "") {
            printf "| %-30s | %-10s |\n", server_name, listen;
        }
    }'
    printf "+--------------------------------+------------+\n"
}

#---------------------------------------------------------
# Function to display active ports or more info about them
#---------------------------------------------------------
activePort() {
    if [ -z "$1" ]; then
        green_echo "Active Ports and Services:"
        printf "+--------+--------+------------+-------------------+\n"
        printf "| %-6s | %-6s | %-10s | %-17s |\n" "PID" "PORT" "PROTOCOL" "PROCESS"
        printf "+--------+--------+------------+-------------------+\n"
        sudo lsof -i -P -n | grep LISTEN | awk '{
            printf "| %-6s | %-6s | %-10s | %-17s |\n", $2, substr($9, index($9,":")+1), $8, $1
        }'
        printf "+--------+--------+------------+-------------------+\n"
    else
        green_echo "Information for port $1:"
        printf "+--------+-------------------------+------------+-----------------+\n"
        printf "| %-6s | %-23s | %-10s | %-15s |\n" "PID" "PORT" "PROTOCOL" "PROCESS"
        printf "+--------+-------------------------+------------+-----------------+\n"
        sudo lsof -i ":$1" | awk 'NR>1 {
            printf "| %-6s | %-23s | %-10s | %-15s |\n", $2, substr($9, index($9,":")+1), $8, $1
        }'
        printf "+--------+-------------------------+------------+-----------------+\n"
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