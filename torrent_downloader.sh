#!/bin/bash

# Define base paths
LOG_DIR=~/Media/logs
MOVIES_DIR=~/Media/Movies

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Prompt destination
echo "Choose destination folder:"
select opt in "Kids - Español" "Kids - English" "Parents"; do
  case $opt in
    "Kids - Español") dest="$MOVIES_DIR/Kids - Español"; break ;;
    "Kids - English") dest="$MOVIES_DIR/Kids - English"; break ;;
    "Parents") dest="$MOVIES_DIR/Parents"; break ;;
    *) echo "Invalid option";;
  esac
done

# Prompt magnet link
read -p "Enter magnet link: " magnet

# Extract torrent name from magnet link (for display purposes)
torrent_name=$(echo "$magnet" | grep -oP 'dn=\K[^&]+' | sed 's/%/\\x/g' | xargs -0 printf '%b')

# Change to destination
cd "$dest" || { echo "Failed to access destination"; exit 1; }

# Launch download with logging
transmission-cli "$magnet" -w "$dest" > /tmp/torrent_temp.log 2>&1 &
pid=$!

# Create PID-based log file (compatible with monitor script)
LOGFILE="$LOG_DIR/log_${pid}.txt"

# Add download metadata to log
echo "Download started at: $(date)" > "$LOGFILE"
echo "Torrent name: $torrent_name" >> "$LOGFILE"
echo "PID: $pid" >> "$LOGFILE"
echo "Destination: $dest" >> "$LOGFILE"
echo "-------------------------------------------" >> "$LOGFILE"

# Use a background job to monitor the download and update the log file
(
  while kill -0 $pid 2>/dev/null; do
    transmission-remote -t $pid -i 2>/dev/null | grep -E "Percent Done|State|Name" >> "$LOGFILE"
    echo "Progress check: $(date)" >> "$LOGFILE"
    echo "-------------------------------------------" >> "$LOGFILE"
    sleep 10
  done
) &

echo "Logging download to $LOGFILE"
echo "Started download with PID $pid for: $torrent_name"
echo "To monitor, run: ./monitor_torrent.sh"

