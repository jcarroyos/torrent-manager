# Torrent Manager

A simple, bash-based torrent management system for downloading and monitoring torrents using Transmission daemon.

## Overview

This project consists of two main scripts:

1. **torrent_downloader.sh**: Adds torrents to Transmission daemon.
2. **monitor_torrent.sh**: Monitors active downloads, tracks progress, and provides management options.

## Features

- Download torrents to organized destination folders
- Monitor download progress in real-time
- View detailed torrent information including progress percentage, speed, and ETA
- Start, stop, and remove torrents
- Clean interface with interactive menu

## Requirements

- macOS (or Linux with minor modifications)
- transmission-daemon and transmission-remote (can be installed via Homebrew on macOS)

```bash
brew install transmission-cli
```

## Setup

1. Clone or download this repository
2. Make the scripts executable:

```bash
chmod +x torrent_downloader.sh
chmod +x monitor_torrent.sh
```

3. The scripts will automatically start transmission-daemon if it's not running

## Usage

### Starting a Download

1. Run the downloader script:

```bash
./torrent_downloader.sh
```

2. Select a destination folder from the menu
3. Enter the magnet link for the torrent you want to download
4. The script will add the torrent to Transmission daemon

### Monitoring and Managing Downloads

1. Run the monitor script:

```bash
./monitor_torrent.sh
```

2. Use the interactive menu to:
   - Refresh status of all downloads
   - View detailed information for a specific torrent
   - Start paused torrents
   - Pause running torrents
   - Remove torrents (with or without data)
   - Monitor downloads in real-time with auto-refresh

## How It Works

- **torrent_downloader.sh**:
  - Ensures transmission-daemon is running
  - Prompts for destination and magnet link
  - Adds the torrent to the queue using transmission-remote
  - Reports the torrent ID for future reference

- **monitor_torrent.sh**:
  - Connects to transmission-daemon using transmission-remote
  - Displays torrent list with progress, speed, and status information
  - Provides an interactive menu for torrent management
  - Allows real-time monitoring with auto-refresh

## Customize

You can customize the download directories by modifying the `MOVIES_DIR` variable in `torrent_downloader.sh`.

## Advanced Usage

For more advanced usage, you can directly use the transmission-remote command:

```bash
# List all torrents with details
transmission-remote -l

# Get detailed info for torrent with ID 1
transmission-remote -t 1 -i

# Check help for more options
transmission-remote --help
```