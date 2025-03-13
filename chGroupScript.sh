#!/bin/bash

# Description: Script to ensure directories inherit their parent group's permissions.
<<<<<<< Updated upstream
# Scheduled to run every hour.
=======
# Scheduled to run every day.
>>>>>>> Stashed changes

# Define project paths
PathProject1="/tank/projects"
PathProject2="/tank/projects2"

# Define cluster hostnames
HostnameCluster1="cluster-storage1"
HostnameCluster2="cluster-storage4"

# Define directories to exclude
ChachaDir="chacha"
ChailabDir="chai-lab"

#Getting the hostname of the server
hostname=$(hostname | awk '{print $1}')

#Checking which server the script will be running
#Depending of the server, the pasth changes
if [ "$hostname" = "$HostnameCluster1" ]; then
	Path="$PathProject1"
else
	Path="$PathProject2"
fi

#Create a new log File for the ouput, with the day, month and year
LogFile="/var/log/chGroupScript_$(date '+%d-%b-%Y').log"
touch "$LogFile"

#Saving the date that the script is being executed
echo "Starting script execution at $date" >> "$LogFile"

#Going through each directory inside of the projects/projects2 directory
#Exclude directories matching "chacha" or "chai-lab"
for dir in "$Path"/*/; do

	if [[ "$dir" != "$ChachaDir" && "$dir" != "$ChailabDir" ]]; then  
		echo "Processing directory: $dir at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
		group_name=$(ls -ld "$dir" | awk '{print $4}')
        	chgrp -R "$group_name" "$dir" 
        	chmod -R g+s "$dir"
		echo "Finished processing: $dir (Group: $group_name) at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
	fi
done

echo "Script execution completed at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"


