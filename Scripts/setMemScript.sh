#!/bin/bash

#"Author: Maria Hernandez
#Email: mehernandez@uchicago.edu"

#Description: Script to set a 50GB memory limit per user in the scratch and scratch2 directories
# Scheduled to run every day.

#Define the name of the script
script="setMemScript"

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

#Define the files
LogDir="/var/log"
ZFSData="$LogDir/zfsListUsers.txt"
LoginDataFe01="$LogDir/loginListUsersFe01.txt"
LoginDataFe02="$LogDir/loginListUsersFe02.txt"
LlData="$LogDir/llData.txt"

#Test Files
ZFSDataLog="$LogDir/zfsListUsersLog.txt"
LoginDataLogFe01="$LogDir/loginListUsersLogFe01.txt"
LoginDataLogFe02="$LogDir/loginListUsersLogFe02.txt"
LlDataLog="$LogDir/llDataLog.txt"
touch "$ZFSDataLog"
touch "$LoginDataLogFe01"
touch "$LoginDataLogFe02"
touch "$LlDataLog"


#Making sure the files exist
touch "$ZFSData"
touch "$LlData"

#Getting all the users with their quota updated
zfs userspace "$Path" | tail -n +2 | awk '{print $3}' | sort > "$ZFSData"

#Getting all the users from a long list command in the Scratch/Starch2 directory
ls -la "$Path" | awk '{print $3}' > "$LlData"

newPath="${Path:1}"

# Loop through each user in the file LoginDataFe01
while read -r user; do
  #Check if the user has a quota already set
  #set the quota in case the user does not have one
  if ! grep -qE "$user" "$ZFSData"; then
        #zfs set userquota@"$user"=50G "$newPath"
        echo "this $user is new, setting quota to 50G" >> "$LoginDataLogFe01"
    fi
done < "$LoginDataFe01"

# Loop through each user in the file LoginDataFe02
while read -r user; do
  #Check if the user has a quota already set
  #set the quota in case the user does not have one
  if ! grep -qE "$user" "$ZFSData"; then
        #zfs set userquota@"$user"=50G "$newPath"
        echo "this $user is new, setting quota to 50G" >> "$LoginDataLogFe02"
    fi
done < "$LoginDataFe02"

# Loop through each user in the file LlData
while read -r user; do
  #Check if the user has a quota already set
    #set the quota in case the user does not have one
    if ! grep -qE "$user" "$ZFSData"; then
          #zfs set userquota@"$user"=50G "$newPath"
          echo "this $user is new, setting quota to 50G" >> "$LlDataLog"
      fi
done < "$LlData"


