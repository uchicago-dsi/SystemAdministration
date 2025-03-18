#!/bin/bash

#"Author: Maria Hernandez
#Email: mehernandez@uchicago.edu"


# Description: Find and delete files older than 60 days - Scratch cluster
# Scheduled to run every day.

# Define scracth paths
PathScratch1="/tank/scratch"
PathScratch2="/tank/scratch2"

# Define cluster hostnames
ClusterScratch1="cluster-storage2"
ClusterScratch2="cluster-storage4"

#Getting the hostname of the server
hostname=$(hostname)

#Checking which server the script will be running
#Depending of the server, the path changes
if [ "$hostname" = "$ClusterScratch1" ]; then
	Path="$PathScratch1"
else
	Path="$PathScratch2"
fi

#Create a new log File for the output, with the day, month and year
LogFile="/var/log/dlFilesScratch_$(date '+%d-%b-%Y').log"
touch "$LogFile"

#Saving the date that the script is being executed
echo "Starting script execution at $(date)" >> "$LogFile"

#Going through only the top-level files and folders inside of the scratch/scratch2 directory
for dir in "$Path"/*/; do
	find "$dir" -maxdepth 1 -atime +60 -exec stat --format="File: %n | Last Access: %x | Last Modified: %y | Created: %W | Owner: %U" {} \; >> "$LogFile"
done

echo "Script execution completed at $(date | awk '{printf "%s\n", $4}')" >> "$LogFile"
