#!/bin/bash

#Author: Maria Hernandez
#Email: mehernandez@uchicago.edu


# Description: Script for getting all the users logged-in and pass the info to the scratch storage clusters
# Scheduled to run every day.


#Define servers_path.txt path
servers_paths="/root/SystemAdministration/server_paths.txt"

#Define the name of the script running on the clusters
scriptClusters="setMemScript"

#Define the name of this script
script="lgUserInfo"

#Getting the hostname of the server
hostname=$(hostname)

#Determine the server where the script is running
#Set the directory path based on the server
#server names and path directories: servers_paths.txt
Path=$(grep "^$hostname $script" "$servers_paths" | awk '{print $3}')

#Creating the file
touch "$Path"

#If the hostname is not on the list, exit the code
if [ -z "$Path" ]; then
  exit 0
fi

#Save the list of users
loginctl list-users --no-legend | awk '{print $2}' > "$Path"

# Loop through the server list and transfer the login data
for name in $(grep "$scriptClusters" "$servers_paths"); do
  su - mehernandez -c "scp $Path mehernandez@$name:/var/log/"
done
