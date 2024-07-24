# DevOpsFetch

DevOpsFetch is a tool for DevOps that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses.

## Installation

1. Clone this repository or download the `devopsfetch` and `install_devopsfetch.sh` scripts.

2. Make both scripts executable:
   ```
   $ chmod +x devopsfetch install_devopsfetch.sh
   ```

3. Run the installation script as root:
   ```
   sudo ./install_devopsfetch.sh
   ```

This will install the necessary dependencies, set up the DevOpsFetch script, and create a systemd service for continuous monitoring.

## Usage

DevOpsFetch can be used with the following command-line flags:

```
devopsfetch [OPTION]... [ARGUMENT]...
```

Options:
- `-p, --port [PORT]`: Display active ports or specific port info
- `-d, --docker [CONTAINER]`: List Docker images/containers or specific container info
- `-n, --nginx [DOMAIN]`: Display Nginx domains/ports or specific domain config
- `-u, --users [USERNAME]`: List users and last login or specific user info
- `-t, --time START END`: Display activities within specified time range
- `-h, --help`: Display help message

Examples:
```
devopsfetch -p                 # List all active ports
devopsfetch -p 80              # Show details for port 80
devopsfetch -d                 # List all Docker images and containers
devopsfetch -d mycontainer     # Show details for 'mycontainer'
devopsfetch -n                 # List all Nginx domains and ports
devopsfetch -n example.com     # Show config for 'example.com'
devopsfetch -u                 # List all users and last login times
devopsfetch -u johndoe         # Show details for user 'johndoe'
devopsfetch -t '2023-01-01 00:00:00' '2023-01-31 23:59:59'
                               # Show activities in January 2023
```

## Logging

DevOpsFetch logs its activities continuously using a systemd service. Logs are stored in `/var/log/devopsfetch.log`. Log rotation is set up to manage log file sizes and retain logs for 7 days.

To view the logs:
```
sudo journalctl -u devopsfetch.service
```

or

```
sudo cat /var/log/devopsfetch.log
```

## Troubleshooting

If you encounter any issues:

1. Check if the service is running:
   ```
   sudo systemctl status devopsfetch.service
   ```
2. View the logs for any error messages:
   ```
   sudo journalctl -u devopsfetch.service
   ```
3. Ensure all dependencies are installed:
   ```
   sudo apt-get install docker.io nginx
   ```

For further assistance, please open an issue in the GitHub repository.