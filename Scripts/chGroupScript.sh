#!/bin/bash

#Author: Maria Hernandez
#Email: mehernandez@uchicago.edu"

# Description: Change the group ownership of directories within the file system to the correct group that belongs
# Scheduled to run every Monday.

#Define the name of the script
script="chGroupScript"

#Define servers_path.txt path
servers_paths="/root/SystemAdministration/server_paths.txt"

# Define directories to exclude
ChailabDir="chai-lab"

#Getting the hostname of the server
hostname=$(hostname)

#Determine the server where the script is running
#Set the directory path based on the server
#server names and path directories: servers_paths.txt
Path=$(grep "^$hostname $script" "$servers_paths" | awk '{print $3}')

#If the hostname is not on the list, exit the code
if [ -z "$Path" ]; then
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


