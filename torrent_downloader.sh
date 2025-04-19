#!/bin/bash

# Define base paths
LOG_DIR=~/Media/logs
MOVIES_DIR=~/Media/Movies

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Check if transmission-daemon is running, if not start it
if ! pgrep -f "transmission-daemon" > /dev/null; then
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

# Extract torrent hash from magnet link
torrent_hash=$(echo "$magnet" | grep -oP 'urn:btih:\K[^&]+' | tr '[:upper:]' '[:lower:]')

# Extract torrent name from magnet link (for display purposes)
torrent_name=$(echo "$magnet" | grep -oP 'dn=\K[^&]+' | sed 's/%/\\x/g' | xargs -0 printf '%b')

# Ensure the destination directory exists
if [ ! -d "$dest" ]; then
    mkdir -p "$dest"
fi

# Add torrent using transmission-remote
echo "Adding torrent: $torrent_name"
add_result=$(transmission-remote --add "$magnet" --download-dir "$dest")

echo "$add_result"
if [[ "$add_result" == *"success"* ]]; then
    echo "Torrent added successfully! Hash: $torrent_hash"
    
    # Wait for transmission to fully register the torrent
    echo "Waiting for transmission to register the torrent..."
    sleep 3
    
    # List all torrents and capture their details
    torrent_list=$(transmission-remote -l)
    
    # Try to find newly added torrent ID using its position (usually most recent)
    torrent_id=$(echo "$torrent_list" | grep -v Sum: | tail -n 1 | awk '{print $1}')
    
    if [ -z "$torrent_id" ] || [ "$torrent_id" == "ID" ]; then
        echo "Warning: Could not automatically determine torrent ID."
        echo "Here are your current torrents:"
        echo "$torrent_list"
        echo "To monitor downloads, run: ./monitor_torrent.sh"
        exit 0
    else
        echo "Successfully added torrent with ID: $torrent_id"
        echo "Destination: $dest"
        echo "To monitor downloads, run: ./monitor_torrent.sh"
    fi
else
    echo "Failed to add torrent"
    exit 1
fi

