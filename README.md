# Torrent Manager

A simple, bash-based torrent management system for downloading and monitoring torrents using transmission-cli.

## Overview

This project consists of two main scripts:

1. **torrent_downloader.sh**: Starts torrent downloads and sets up logging.
2. **monitor_torrent.sh**: Monitors active downloads, tracks progress, and provides management options.

## Features

- Download torrents to organized destination folders
- Monitor download progress in real-time
- View detailed download status and logs
- Stop downloads when needed
- Consistent logging with progress tracking

## Requirements

- macOS (or Linux with minor modifications)
- transmission-cli (can be installed via Homebrew on macOS)

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

3. Ensure the log directory exists or is created automatically by the script:

```bash
mkdir -p ~/Media/logs
```

## Usage

### Starting a Download

1. Run the downloader script:

```bash
./torrent_downloader.sh
```

2. Select a destination folder from the menu
3. Enter the magnet link for the torrent you want to download
4. The script will start the download and begin tracking progress

### Monitoring Downloads

1. Run the monitor script:

```bash
./monitor_torrent.sh
```

2. Use the interactive menu to:
   - Refresh status of all downloads
   - Monitor a specific download in real-time
   - Stop unwanted downloads
   - View detailed logs for specific downloads

## How It Works

- **torrent_downloader.sh**:
  - Prompts for destination and magnet link
  - Starts transmission-cli in the background
  - Creates a log file named after the process ID
  - Sets up a monitoring process to track download progress

- **monitor_torrent.sh**:
  - Scans for active transmission-cli processes
  - Extracts and displays download information
  - Provides options for managing downloads
  - Allows real-time monitoring of specific downloads

## Log Files

Log files are stored in `~/Media/logs` with filenames in the format `log_PID.txt` where PID is the process ID of the transmission-cli process.

Each log contains:
- Download metadata (start time, torrent name, destination)
- Regular progress updates
- Download state information

## Customize

You can customize the download directories by modifying the `MOVIES_DIR` variable in `torrent_downloader.sh`.