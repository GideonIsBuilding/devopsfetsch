#!/bin/bash
DEVOPSFETCH(8) Manual                                                                                                     DEVOPSFETCH(8)

NAME
     devopsfetch — HTTP and reverse proxy server, mail proxy server

SYNOPSIS
     devopsfetch [-?hqTtVv] [-c file] [-g directives] [-p prefix] [-s signal]

DESCRIPTION
     devopsfetch (pronounced “devops-fetch”) is a DevOps tool that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses.

     The options are as follows:

     -d docker     List all Docker images and containers.

     -h help       Print help.

     -n nginx      Display all Nginx domains and their ports.

     -p port       Display all active ports and services.

     -u users      List all users and their last login times.

     -t time       Display activities within a specified time range.




sudo ss -tulpn | grep LISTEN

sudo lsof -i :42727

docker container ls

docker ps -a && docker images

docker inspect $

sudo nginx -T | grep "server_name "

grep -r "listen" /etc/nginx | grep -oP "listen\s+\K(\d+)"

