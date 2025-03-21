#!/bin/bash

#Script to set a 50GB memory limit per user in the scratch and scratch2 directories

# Define cluster hostnames
ClusterScratch1="cluster-storage2"
ClusterScratch2="cluster-storage4"

# Define scracth paths
PathScratch1="/tank/scratch"
PathScratch2="/tank/scratch2"

#Define the files
LogDir="/var/log"
ZFSData="$LogDir/zfsListUsers.txt"
LoginData="$LogDir/loginListUsers.txt"
LlData="$LogDir/llData.txt"
AllUsers="$LogDir/allUsers.txt"

#Test Files
ZFSDataLog="$LogDir/zfsListUsersLog.txt"
LoginDataLog="$LogDir/loginListUsersLog.txt"
LlDataLog="$LogDir/llDataLog.txt"
touch "$ZFSDataLog"
touch "$LoginDataLog"
touch "$LlDataLog"
touch "$AllUsers"


#Making sure the files exist
touch "$ZFSData"
touch "$LlData"


#Getting the hostname of the server
hostname=$(hostname)

#Checking which server the script will be running
#Depending of the server, the path changes
if [ "$hostname" = "$ClusterScratch1" ]; then
	Path="$PathScratch1"
elif [ "$hostname" = "$ClusterScratch2" ]; then
	Path="$PathScratch2"
else
  #If the hostname is not listed among the defined clusters in line 14, the script will exit without displaying an error message
	  exit 0;
fi

# If the file is empty, add the header
if [ ! -s "$AllUsers" ]; then
  echo "Users with a 50GB memory limit in the scratch and scratch2 directories." > "$AllUsers"
  echo "" >> "$AllUsers"
fi

#Getting all the users by zfs
zfs userspace "$Path" | tail -n +2 | awk '{print $3}' | sort > "$ZFSData"

#Getting all the users from a long list command in the Scratch/Starch2 directory
ls -la "$Path" | awk '{print $3}' > "$LlData"

newPath="${Path:1}"

# Loop through each user in the file
while read -r user; do
  zfs set userquota@"$user"=50G "$newPath"
  echo "$user" >> "$ZFSDataLog"

  #check if the user is in the All user files.
  if ! grep -qE "^zfs set userquota@ $user =50G $newPath$" "$AllUsers"; then
        echo "zfs set userquota@ $user =50G $newPath" >> "$AllUsers"
  fi

done < "$ZFSData"

# Loop through each user in the file
while read -r user; do
  zfs set userquota@"$user"=50G "$newPath"
  echo "$user" >> "$LoginDataLog"

  #check if the user is in the All user files.
  if ! grep -qE "^zfs set userquota@ $user =50G $newPath$" "$AllUsers"; then
      echo "zfs set userquota@ $user =50G $newPath" >> "$AllUsers"
  fi


done < "$LoginData"

# Loop through each user in the file
while read -r user; do
  zfs set userquota@"$user"=50G "$newPath"
  echo "$user" >> "$LlDataLog"

  #check if the user is in the All user files.
    if ! grep -qE "^zfs set userquota@ $user =50G $newPath$" "$AllUsers"; then
          echo "zfs set userquota@ $user =50G $newPath" >> "$AllUsers"
    fi

done < "$LlData"


