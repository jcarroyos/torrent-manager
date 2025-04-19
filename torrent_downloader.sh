#!/bin/bash

# Define base paths
LOG_DIR=~/Media/logs
MOVIES_DIR=~/Media/Movies

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Check if transmission-daemon is running, if not start it
if ! pgrep -x "transmission-daemon" > /dev/null; then
    echo "Starting transmission daemon..."
    transmission-daemon
    # Give daemon time to start
    sleep 2
fi

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

# Ensure the destination directory exists
if [ ! -d "$dest" ]; then
    mkdir -p "$dest"
fi

# Add torrent using transmission-remote
echo "Adding torrent: $torrent_name"
transmission-remote --add "$magnet" --download-dir "$dest"

# Get the ID of the newly added torrent
sleep 2  # Give time for the torrent to be added
torrent_id=$(transmission-remote -l | grep -i "$torrent_name" | awk '{print $1}')

if [ -z "$torrent_id" ]; then
    echo "Failed to add torrent or retrieve torrent ID"
    exit 1
fi

echo "Successfully added torrent with ID: $torrent_id"
echo "Destination: $dest"
echo "To monitor downloads, run: ./monitor_torrent.sh"

