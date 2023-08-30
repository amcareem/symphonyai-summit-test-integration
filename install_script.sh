#!/bin/bash

# Update the system
apt-get update
apt-get upgrade -y

# Install Python and Pip
apt-get install -y python3 python3-pip git

# Install required Python libraries
pip3 install requests

# Download the Python script from Github after I store the code
git clone https://repo-url/path/to/script.git /opt/ticket_monitor

# Start the script
nohup python3 /opt/ticket_monitor/my_script_name.py &
