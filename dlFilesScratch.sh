#!/bin/bash

# Description: Find and delete files older than 60 days 
# Scheduled to run every day.

PathScratch1="/tank/scratch"
PathProject2="/tank/scratch2"
ClusterScratch1="cluster-storage2"
ClusterScratch2="cluster-storage4"

hostname=$(hostname)

if [ "$hostname" = "$ClusterScratch1" ]; then
	Path="$PathProject1"
else
	Path="$PathProject2"
fi
        
for dir in "$Path"/*/; do
	find "$dir" -type f -atime +60 -exec stat --format="File: %n | Last Access: %x | Last Modified: %y | Created: %W | Owner: %U" {} \; >> /var/log/dlFilesScratch.log 2>&1 
done


