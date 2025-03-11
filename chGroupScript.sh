#!/bin/bash

# Description: Script to ensure directories inherit their parent group's permissions.
# Scheduled to run every hour.

PathProject1="/tank/projects/"
PathProject2="/tank/projects2/"
HostnameCluster1="cluster-storage1"
HostnameCluster2="cluster-storage4"

hostname=$(hostname | awk '{print $1}')

if [ "$hostname" = "$HostnameCluster1" ]; then
	Path="$PathProject1"
else
	Path="$PathProject2"
fi
        
for dir in "$Path"*/; do
	group_name=$(ls -ld "$dir" | awk '{print $4}')
        chgrp -R "$group_name" "$dir" 
        chmod -R g+s "$dir"
done


