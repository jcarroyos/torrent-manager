#!/bin/bash

LOG_DIR=~/Media/logs

# Check if transmission-daemon is running
check_daemon_running() {
  if ! pgrep -f "transmission-daemon" > /dev/null; then
    echo "Transmission daemon is not running. Starting it..."
    transmission-daemon
    # Give daemon time to start
    sleep 2
  fi
}

# Function to display active downloads with progress information
display_downloads() {
  check_daemon_running

  # Get torrent list from transmission-remote
  transmission_output=$(transmission-remote -l)
  
  if [ $? -ne 0 ]; then
    echo "Failed to connect to transmission daemon."
    return 1
  fi
  
  # Count torrents (subtract 2 for header and footer lines)
  torrent_count=$(echo "$transmission_output" | wc -l)
  torrent_count=$((torrent_count - 2))
  
  if [ $torrent_count -eq 0 ]; then
    echo "No active downloads found."
    return 1
  fi
  
  echo "Active downloads:"
  echo "$transmission_output" | head -n 1  # Print header
  echo "----------------------------------------------"
  
  # Print torrent list without header and sum line
  echo "$transmission_output" | sed -n '2,$ {/^\s*Sum:/d; p}'
  
  return 0
}

# Function to get detailed info about a torrent
get_torrent_details() {
  local torrent_id=$1
  transmission-remote -t $torrent_id -i
}

# Function to stop a torrent
stop_torrent() {
  local torrent_id=$1
  transmission-remote -t $torrent_id --stop
  echo "Stopped torrent with ID: $torrent_id"
}

# Function to start a torrent
start_torrent() {
  local torrent_id=$1
  transmission-remote -t $torrent_id --start
  echo "Started torrent with ID: $torrent_id"
}

# Function to remove a torrent
remove_torrent() {
  local torrent_id=$1
  local remove_data=$2
  
  if [ "$remove_data" = "true" ]; then
    transmission-remote -t $torrent_id --remove-and-delete
    echo "Removed torrent and data with ID: $torrent_id"
  else
    transmission-remote -t $torrent_id --remove
    echo "Removed torrent (kept data) with ID: $torrent_id"
  fi
}

# Interactive menu
show_menu() {
  echo
  echo "Options:"
  echo "1. Refresh status"
  echo "2. View detailed info for a torrent"
  echo "3. Start a paused torrent"
  echo "4. Stop/pause a torrent"
  echo "5. Remove a torrent"
  echo "6. Remove a torrent and its data"
  echo "7. Monitor downloads in real-time"
  echo "8. Exit"
  echo
  read -p "Choose an option: " choice
  
  case $choice in
    1) 
       clear
       display_downloads
       show_menu 
       ;;
    2) 
       read -p "Enter torrent ID: " torrent_id
       clear
       get_torrent_details "$torrent_id"
       echo
       read -p "Press Enter to continue..."
       clear
       display_downloads
       show_menu 
       ;;
    3) 
       read -p "Enter torrent ID to start: " torrent_id
       start_torrent "$torrent_id"
       sleep 1
       clear
       display_downloads
       show_menu 
       ;;
    4) 
       read -p "Enter torrent ID to stop/pause: " torrent_id
       stop_torrent "$torrent_id"
       sleep 1
       clear
       display_downloads
       show_menu 
       ;;
    5) 
       read -p "Enter torrent ID to remove (keep data): " torrent_id
       remove_torrent "$torrent_id" false
       sleep 1
       clear
       display_downloads
       show_menu 
       ;;
    6) 
       read -p "Enter torrent ID to remove WITH DATA (cannot be undone): " torrent_id
       read -p "Are you sure you want to delete the data? (y/n): " confirm
       if [ "$confirm" = "y" ]; then
         remove_torrent "$torrent_id" true
       else
         echo "Operation cancelled."
       fi
       sleep 1
       clear
       display_downloads
       show_menu 
       ;;
    7)
       echo "Monitoring downloads in real-time. Press Ctrl+C to stop."
       echo
       while true; do
         clear
         echo "Refreshed at: $(date '+%H:%M:%S')"
         display_downloads
         sleep 3
       done
       ;;
    8) exit 0 ;;
    *) echo "Invalid option"; show_menu ;;
  esac
}

# Main execution
clear
if display_downloads; then
  show_menu
else
  echo
  echo "Would you like to:"
  echo "1. Start transmission daemon and try again"
  echo "2. Exit"
  read -p "Choose an option: " choice
  
  if [ "$choice" = "1" ]; then
    transmission-daemon
    sleep 2
    clear
    if display_downloads; then
      show_menu
    else
      echo "Still no torrents. Add a torrent using ./torrent_downloader.sh"
    fi
  fi
fi

