#!/bin/bash

# Description: Script to ensure directories inherit their parent group's permissions.
# Scheduled to run every hour.

PathProject1="/net/projects/"
PathProject2="/net/projects2/"

for dir in "$PathProject1"*/; do
	group_name=$(ls -ld "$dir" | awk '{print $4}')
	chgrp -R "$group_name" "$dir" 
	chmod -R g+s "$dir"
done

for dir in "$PathProject2"*/; do
	group_name=$(ls -ld "$dir" | awk '{print $4}') 
        chgrp -R "$group_name" "$dir" 
        chmod -R g+s "$dir"
done

