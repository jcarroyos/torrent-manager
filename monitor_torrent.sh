#!/bin/bash

LOG_DIR=~/Media/logs

# Function to extract torrent name from magnet link
extract_torrent_name() {
  local magnet_link="$1"
  local encoded_name=$(echo "$magnet_link" | grep -oP 'dn=\K[^&]+')
  printf '%b\n' "${encoded_name//%/\\x}"
}

# Function to extract progress percentage from log file
extract_progress() {
  local pid="$1"
  local logfile="$LOG_DIR/log_${pid}.txt"
  
  if [[ -f "$logfile" ]]; then
    # Try to get progress from transmission-remote output first
    local percent=$(grep "Percent Done" "$logfile" | tail -1 | awk '{print $NF}')
    
    # If that doesn't work, try the old method
    if [ -z "$percent" ]; then
      percent=$(grep -oP 'Progress: \K[0-9.]+%' "$logfile" | tail -1)
    fi
    
    # If still empty, check for download complete message
    if [ -z "$percent" ]; then
      if grep -q "Download is complete" "$logfile"; then
        percent="100%"
      fi
    fi
    
    # Return result or N/A
    if [ -n "$percent" ]; then
      echo "$percent"
    else
      echo "N/A"
    fi
  else
    echo "No log file"
  fi
}

# Function to extract download state
extract_state() {
  local pid="$1"
  local logfile="$LOG_DIR/log_${pid}.txt"
  
  if [[ -f "$logfile" ]]; then
    local state=$(grep "State" "$logfile" | tail -1 | awk '{$1=""; print $0}' | sed 's/^[ \t]*//')
    
    if [ -n "$state" ]; then
      echo "$state"
    else
      echo "Unknown"
    fi
  else
    echo "Unknown"
  fi
}

# Function to display download info
display_download_info() {
  local active_downloads=$(ps aux | grep 'transmission-cli magnet:' | grep -v 'grep')
  
  if [ -z "$active_downloads" ]; then
    echo "No active downloads found."
    return 1
  fi
  
  echo "Active downloads:"
  echo

  IFS=$'\n' read -rd '' -a lines <<<"$active_downloads"
  for i in "${!lines[@]}"; do
    line="${lines[$i]}"
    pid=$(echo "$line" | awk '{print $2}')
    magnet_link=$(echo "$line" | grep -o 'magnet:.*')
    
    # Get name from log file first if available
    local logfile="$LOG_DIR/log_${pid}.txt"
    if [[ -f "$logfile" ]]; then
      readable_name=$(grep "Torrent name:" "$logfile" | head -1 | sed 's/Torrent name: //')
    fi
    
    # Fallback to extraction from magnet link
    if [ -z "$readable_name" ]; then
      readable_name=$(extract_torrent_name "$magnet_link")
    fi
    
    progress=$(extract_progress "$pid")
    state=$(extract_state "$pid")
    
    echo "$((i + 1)). [$pid] $readable_name"
    echo "   Progress: $progress | State: $state"
  done
  
  return 0
}

# Interactive menu
show_menu() {
  echo
  echo "Options:"
  echo "1. Refresh status"
  echo "2. Monitor download in real-time"
  echo "3. Stop a download"
  echo "4. View detailed log"
  echo "5. Exit"
  echo
  read -p "Choose an option: " choice
  
  case $choice in
    1) clear; display_download_info; show_menu ;;
    2) 
      clear
      read -p "Enter download number to monitor: " number
      selected="${lines[$((number - 1))]}"
      pid_to_monitor=$(echo "$selected" | awk '{print $2}')
      
      if [[ -n "$pid_to_monitor" ]]; then
        echo "Monitoring download [$pid_to_monitor]. Press Ctrl+C to stop."
        while true; do
          clear
          echo "Download: $(grep 'Torrent name:' "$LOG_DIR/log_${pid_to_monitor}.txt" | head -1 | sed 's/Torrent name: //')"
          echo "Progress: $(extract_progress "$pid_to_monitor")"
          echo "State: $(extract_state "$pid_to_monitor")"
          echo
          echo "Last log entries:"
          tail -10 "$LOG_DIR/log_${pid_to_monitor}.txt"
          sleep 2
        done
      else
        echo "Invalid selection."
      fi
      show_menu
      ;;
    3)
      read -p "Enter number to stop: " number
      selected="${lines[$((number - 1))]}"
      pid_to_kill=$(echo "$selected" | awk '{print $2}')
      
      if [[ -n "$pid_to_kill" ]]; then
        kill -9 "$pid_to_kill"
        echo "Download [$pid_to_kill] stopped."
      else
        echo "Invalid selection."
      fi
      show_menu
      ;;
    4)
      read -p "Enter download number to view log: " number
      selected="${lines[$((number - 1))]}"
      pid_to_view=$(echo "$selected" | awk '{print $2}')
      
      if [[ -n "$pid_to_view" ]]; then
        less "$LOG_DIR/log_${pid_to_view}.txt"
      else
        echo "Invalid selection."
      fi
      show_menu
      ;;
    5) exit 0 ;;
    *) echo "Invalid option"; show_menu ;;
  esac
}

# Main execution
clear
if display_download_info; then
  show_menu
fi

