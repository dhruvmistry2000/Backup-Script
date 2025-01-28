#!/bin/bash

# Source directory and backup directories
SOURCE_DIR="/home/dhruv/Github/myneovim"    # Where to backup from
BACKUP_DIR="/home/dhruv/Document"          # Where to store backups locally  
REMOTE_NAME="gdrive"                       # rclone remote name
REMOTE_DIR="/backup"                       # Remote backup folder

# How many days of backups to keep
DAYS_TO_KEEP=7

# Function to check prerequisites and create directories
check_prerequisites() {
    # Check if source directory is set
    if [ -z "$SOURCE_DIR" ]; then
        echo "Error: Source directory not set!"
        exit 1
    fi

    # Check if backup directory is set  
    if [ -z "$BACKUP_DIR" ]; then
        echo "Error: Backup directory not set!"
        exit 1
    fi

    # Check if remote name is set
    if [ -z "$REMOTE_NAME" ]; then
        echo "Error: Remote name not set!"
        exit 1
    fi

    # Make sure rclone exists
    if ! command -v rclone &> /dev/null; then
        echo "Please install rclone first!"
        exit 1
    fi

    # Create backup folder if needed
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Making backup folder: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    # Setup backup file names
    MONTH=$(date +%B_%Y)
    TIMESTAMP=$(date +%H%M%S_%d%m%Y)
    MONTH_DIR="${BACKUP_DIR}/${MONTH}"
    BACKUP_FILE="backup_${TIMESTAMP}.zip"

    # Create month folder if needed
    if [ ! -d "$MONTH_DIR" ]; then
        echo "Making month folder: $MONTH_DIR"
        mkdir -p "$MONTH_DIR"
    fi
}

# Function to perform backup operations
backup() {
    # Create local backup
    echo "Starting backup..."
    zip -r "${MONTH_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" > local.log
    if [ $? -eq 0 ]; then
        echo "Backup done: ${MONTH_DIR}/${BACKUP_FILE}"
    else
        echo "Backup failed!"
        exit 1
    fi

    # Copy to remote storage
    echo "Copying to remote storage..."
    rclone copy "${MONTH_DIR}/${BACKUP_FILE}" "$REMOTE_NAME:$REMOTE_DIR/${MONTH}" > remote.log
    if [ $? -eq 0 ]; then
        echo "Remote copy done!"
    else
        echo "Remote copy failed!"
        exit 1
    fi
}

# Function to clean up old backups
delete_backups() {
    # Clean up old local backups
    echo "Cleaning old backups..."

    # Get date from X days ago
    OLD_DATE=$(date -d "$DAYS_TO_KEEP days ago" +%s)
    OLD_MONTH_DATE=$(date -d "3 months ago" +%s)

    # Find and remove old backups
    find "$BACKUP_DIR" -type f -name "backup_*" | while read backup_file; do
        file_date=$(stat -c %Y "$backup_file")
        if [ $file_date -lt $OLD_DATE ]; then
            echo "Removing old backup: $backup_file"
            rm -f "$backup_file"
        fi
    done

    # Find and remove old month directories
    find "$BACKUP_DIR" -q 1 -maxdepth 1 -type d | while read month_dir; do
        dir_date=$(stat -c %Y "$month_dir")
        if [ $dir_date -lt $OLD_MONTH_DATE ]; then
            echo "Removing old month directory: $month_dir"
            rm -rf "$month_dir"
        fi
    done

    echo "Local cleanup done!"

    # Clean up old remote backups
    echo "Cleaning remote backups..."

    # Delete old remote backups
    rclone delete "$REMOTE_NAME:$REMOTE_DIR" \
        --min-age "${DAYS_TO_KEEP}d" \
        --include "backup_*" > remote_cleanup.log

    if [ $? -eq 0 ]; then
        echo "Remote cleanup done!"
    else
        echo "Remote cleanup failed!"
        exit 1
    fi

    echo "All done! Backup complete!"
}

# Main execution
check_prerequisites
backup
delete_backups