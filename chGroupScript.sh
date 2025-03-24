#!/bin/bash

#"Author: Maria Hernandez
#Email: mehernandez@uchicago.edu"

# Define project paths
PathProject1="/tank/projects"
PathProject2="/tank/projects2"

# Define cluster hostnames
HostnameCluster1="cluster-storage1"
HostnameCluster2="cluster-storage4"

# Define directories to exclude
ChailabDir="chai-lab"

#Getting the hostname of the server
hostname=$(hostname)

#Checking which server the script will be running
#Depending of the server, the path changes
if [ "$hostname" = "$HostnameCluster1" ]; then
	Path="$PathProject1"
elif [ "$hostname" = "$HostnameCluster2" ]; then
	Path="$PathProject2"
else
  #If the hostname is not listed among the defined clusters in line 14, the script will exit without displaying an error message
  exit 0
fi

#Create a new log File for the ouput, with the day, month and year
LogFile="/var/log/chGroupScript_$(date '+%d-%b-%Y').log"
touch "$LogFile"

#Saving the date that the script is being executed
echo "Starting script execution at $(date)" >> "$LogFile"

#Going through each directory inside of the projects/projects2 directory
#Exclude directories matching any of our directories listed on line 14
for dir in "$Path"/*/; do

	if [[ "$(basename "$dir")" != "$ChailabDir" ]]; then
		echo "Processing directory: $dir at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
		group_name=$(ls -ld "$dir" | awk '{print $4}')
        	chgrp -R "$group_name" "$dir"
        	chmod -R g+s "$dir"
		echo "Finished processing: $dir (Group: $group_name) at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
	fi
done

echo "Script execution completed at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"


