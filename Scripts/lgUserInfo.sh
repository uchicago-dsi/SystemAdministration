#!/bin/bash

#Author: Maria Hernandez
#Email: mehernandez@uchicago.edu


# Description: Script for getting all the users logged-in and pass the info to the scratch storage clusters
# Scheduled to run every day.


#Define servers_path.txt path
servers_paths="/root/SystemAdministration/servers_paths.txt"

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
#Assigning privileges to others users
chmod 755 "$Path"

#If the hostname is not on the list, exit the code
if [ -z "$Path" ]; then
  exit 0
fi

#Save the list of users
loginctl list-users --no-legend | awk '{print $2}' > "$Path"

clusterName="/var/log/clusterNames"
touch "$clusterName"

grep "$scriptClusters" "$servers_paths" | awk '{print $1}'  > "$clusterName"

# Loop through the server list and transfer the login data
while read -r name; do
  echo "this is a cluster name $name" >> "$Path"
  #Copying the logged-in users information in each cluster
  su - mehernandez -c "scp $Path mehernandez@$name:/home/mehernandez"
done < "$clusterName"
