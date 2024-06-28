#!/bin/bash

# Set source and destination directories
SRC_DIR="$HOME/projects/detail/apps/backend/metabase-data"
DEST_DIR="$HOME/backups/metabase"

# Create timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup filename
BACKUP_FILE="metabase_backup_$TIMESTAMP.tar.gz"

# Function to show a notification
show_notification() {
	title="$1"
	message="$2"
	osascript -e "display notification \"$message\" with title \"$title\""
}

# Function to show an alert (dialog box)
show_alert() {
	title="$1"
	message="$2"
	osascript -e "display alert \"$title\" message \"$message\""
}

# Ensure destination directory exists
mkdir -p "$DEST_DIR"

# Perform backup
if [ -d "$SRC_DIR" ]; then
	tar -czf "$DEST_DIR/$BACKUP_FILE" -C "$(dirname "$SRC_DIR")" "$(basename "$SRC_DIR")" || {
		show_alert "Backup Failed" "Error during tar operation"
		exit 1
	}
else
	show_alert "Backup Failed" "Source directory not found"
	exit 1
fi

# Verify backup file was created
if [ -f "$DEST_DIR/$BACKUP_FILE" ]; then
	show_notification "Backup Successful" "Backup created: $BACKUP_FILE"
else
	show_alert "Backup Failed" "Backup file not created"
	exit 1
fi
