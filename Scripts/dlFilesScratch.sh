#!/bin/bash

#"Author: Maria Hernandez
#Email: mehernandez@uchicago.edu"


# Description: Find and delete files older than 60 days - Scratch cluster
# Scheduled to run every day.

#Define the name of the script
script="dlFilesScratch"

#Define servers_path.txt path
servers_paths="/root/SystemAdministration/servers_paths.txt"

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

#Define logs path
LogsPath="/var/log"

#Create a new log File for the output, with the day, month and year
LogFile="/var/log/dlFilesScratch_$(date '+%d-%b-%Y').log"
touch "$LogFile"

#Saving the date that the script is being executed
echo "Starting script execution at $(date)" >> "$LogFile"

#Going through only the top-level files and folders inside of the scratch/scratch2 directory
#Checking the modification date of each top-level dir.
#If the dir is older than 60 days, delete it
for dir in "$Path"/*/; do
	find "$dir" -maxdepth 0 -type d -mtime +60 -printf "%A+ | Type: %y | Path: %p | Owner: %u | *** has been deleted from the cluster ***\n" >> "$LogFile"
done

#Remove old log files (older than 7 days)
find "$LogsPath" -type f -name "dlFilesScratch_*" -atime +7 -exec rm -f {} \;

echo "Script execution completed at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
