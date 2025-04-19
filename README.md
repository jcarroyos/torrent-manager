# Torrent Manager

A simple bash-based torrent management system using Transmission daemon.

## Scripts

- **torrent_downloader.sh**: Adds torrents to specific destination folders
- **monitor_torrent.sh**: Monitors downloads and provides management options

## Requirements

- macOS or Linux
- transmission-cli (`brew install transmission-cli` on macOS)

## Quick Start

1. Make scripts executable:
   ```
   chmod +x torrent_downloader.sh monitor_torrent.sh
   ```

2. Download a torrent:
   ```
   ./torrent_downloader.sh
   ```
   Follow the prompts to select destination folder and enter a magnet link.

3. Monitor downloads:
   ```
   ./monitor_torrent.sh
   ```
   Use the interactive menu to manage torrents.

## Features

- Organized downloads in categorized folders
- Real-time progress monitoring
- Start, stop, and remove torrents
- Interactive menu interface

The scripts automatically start transmission-daemon if it's not already running.

## Screenshot
<img width="2048" alt="Screenshot 2025-04-19 at 10 18 09 AM" src="https://github.com/user-attachments/assets/874e7f3a-3500-4f6b-bd55-61baf4d1ef18" />
