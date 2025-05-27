#!/bin/bash
#
# cleanup_inactive_users.sh
# 
# Purpose: Identify user directories under /tank/scratch that haven't been accessed in 60+ days
# The script uses an optimized approach: it checks the top-level directory's atime first,
# then only scans until it finds one file with a newer access time than the top-level directory.
# 
# TEST/DRY-RUN MODE: This version only reports actions but DOES NOT actually delete anything.

# Configuration
CUTOFF_DAYS=60
DRY_RUN=false  # Set to true for testing (no deletions)

log() {
  local message="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] $message"
}

log "Starting optimized inspection of inactive directories in /tank/scratch (DRY RUN MODE)"
log "Cutoff period: $CUTOFF_DAYS days"
log "NOTE: No directories will be deleted in this dry run"

# Calculate the cutoff timestamp in seconds since epoch
CURRENT_TIME=$(date +%s)
CUTOFF_TIME=$((CURRENT_TIME - CUTOFF_DAYS * 86400))

# Check if root directory exists and is accessible
if [ ! -d "/tank/scratch" ]; then
  log "ERROR: /tank/scratch directory does not exist or is not accessible"
  exit 1
fi

# Function to check if a directory has recent activity
# Returns: 0 if recent activity found, 1 if no recent activity
check_directory_activity() {
  local dir="$1"
  local dir_atime="$2"
  local found_recent=1  # Default to no recent activity

  # Use find with -newer predicate to efficiently find newer files
  # The -quit flag makes find exit after the first match
  if find "$dir" -type f -newer "$dir" -quit 2>/dev/null; then
    # Found at least one file newer than the directory
    log "Found at least one file with more recent access time than the directory itself"
    
    # Update the directory's atime to reflect activity (even though it's not the most recent)
    if [ "$DRY_RUN" = false ]; then
      touch -a "$dir"
      log "Updated atime for $dir"
    else
      log "Would update atime for $dir (skipped in dry run)"
    fi
    
    found_recent=0  # Recent activity found
  fi

  return $found_recent
}

# Process each user directory
find "/tank/scratch" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' user_dir; do
  user=$(basename "$user_dir")
  log "Processing user directory: $user"
  
  # Check if we have permission to read the directory
  if [ ! -r "$user_dir" ]; then
    log "WARNING: No read permission for $user_dir - skipping"
    continue
  fi

  # Get the directory's own atime
  dir_atime=$(stat -c '%X' "$user_dir" 2>/dev/null)
  if [ -z "$dir_atime" ]; then
    log "ERROR: Cannot determine access time for directory $user_dir - skipping"
    continue
  fi
  
  # Check if the directory's own atime is recent enough
  if [ "$dir_atime" -ge "$CUTOFF_TIME" ]; then
    days_ago=$(( (CURRENT_TIME - dir_atime) / 86400 ))
    log "WOULD KEEP: $user_dir - directory atime is $days_ago days ago (within $CUTOFF_DAYS day threshold)"
    continue
  fi
  
  # Directory atime is old, but check if any files inside have more recent activity
  log "Directory atime is old ($(date -d @$dir_atime "+%Y-%m-%d %H:%M:%S")) - checking for recent file activity"
  
  # Check for any file with newer atime than the directory itself
  if check_directory_activity "$user_dir" "$dir_atime"; then
    # No recent activity found, directory should be deleted
    days_ago=$(( (CURRENT_TIME - dir_atime) / 86400 ))
    log "WOULD DELETE: $user_dir - no recent activity detected, last access was $days_ago days ago"
  else
    # Recent activity found, directory should be kept
    log "WOULD KEEP: $user_dir - recent activity detected in subdirectories"
  fi
done

log "Inspection complete - run without DRY_RUN=true to perform actual deletions"
exit 0
