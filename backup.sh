#!/bin/bash

# Source directory and backup directories
SOURCE_DIR="/path/to/source/dir"                # Where to backup from
BACKUP_DIR="/path/to/local/backup/dir"          # Where to store backups locally  
REMOTE_NAME="remote/drive/name"                 # rclone remote name
REMOTE_DIR="remote/dir/path"                    # Remote backup folder           
DAYS_TO_KEEP=7                                  # How many days of backups to keep
DISABLE_NOTIFICATION=false                       # Option to disable cURL request for testing

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

    # Create backup folder if needed
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Making backup folder: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    # Create log directory if needed
    if [ ! -d "/var/log/backup" ]; then
        sudo mkdir -p "/var/log/backup"
        sudo chown $USER:$USER "/var/log/backup"
    fi

    # Setup backup file names
    HOSTNAME=$(cat /etc/hostname)
    MONTH=$(date +%B_%Y)
    TIMESTAMP=$(date +%H%M%S_%d%m%Y)
    HOST_DIR="${BACKUP_DIR}/${HOSTNAME}"
    MONTH_DIR="${HOST_DIR}/${MONTH}"
    BACKUP_FILE="backup_${TIMESTAMP}.zip"

    # Create month folder if needed
    if [ ! -d "$MONTH_DIR" ]; then
        echo "Making month folder: $MONTH_DIR"
        mkdir -p "$MONTH_DIR"
    fi

    # Check if rclone is installed
    if ! command -v rclone &> /dev/null; then
        echo "Error: rclone is not installed. Please install rclone and configure to proceed!"
        echo "Refer to following link https://rclone.org/downloads/"
        exit 1
    fi
}

# Function to perform backup operations
backup() {
    # Create local backup
    echo "Starting backup..."
    zip -r "${MONTH_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" > "/var/log/backup/local.log" 2>&1
    if [ $? -eq 0 ]; then
        echo "Backup done: ${MONTH_DIR}/${BACKUP_FILE}"
    else
        echo "Backup failed!"
        exit 1
    fi

    # Copy to remote storage
    echo "Copying to remote storage..."
    rclone copy "${MONTH_DIR}/${BACKUP_FILE}" "$REMOTE_NAME:$REMOTE_DIR/${MONTH}" > "/var/log/backup/remote.log" 2>&1
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

    # Find and remove old backups securely
    find "$BACKUP_DIR" -type f -name "backup_*" | while read -r backup_file; do
        file_date=$(stat -c %Y "$backup_file")
        if [ "$file_date" -lt "$OLD_DATE" ]; then
            echo "Removing old backup: $backup_file"
            rm -f "$backup_file"
        fi
    done

    # Find and remove old month directories securely
    find "$BACKUP_DIR" -maxdepth 1 -type d | while read -r month_dir; do
        dir_date=$(stat -c %Y "$month_dir")
        if [ "$dir_date" -lt "$OLD_MONTH_DATE" ]; then
            echo "Removing old month directory: $month_dir"
            rm -rf "$month_dir"
        fi
    done

    echo "Local cleanup done!"

    # Clean up old remote backups
    echo "Cleaning remote backups..."

    # Delete old remote backups securely
    rclone delete "$REMOTE_NAME:$REMOTE_DIR" \
        --min-age "${DAYS_TO_KEEP}d" \
        --include "backup_*" > "/var/log/backup/remote_cleanup.log" 2>&1

    if [ $? -eq 0 ]; then
        echo "Remote cleanup done!"
    else
        echo "Remote cleanup failed!"
        exit 1
    fi

    echo "All done! Backup complete!"
}

# Function to send notification
send_notification() {
    if [ "$DISABLE_NOTIFICATION" = false ]; then
        curl -X POST -H "Content-Type: application/json" -d '{
            "project": "'"$SOURCE_DIR"'",
            "date": "'"$TIMESTAMP"'",
            "test": "BackupSuccessful"
        }' http://<SERVER_IP_ADDRESS>/posts
    else
        echo "Notification disabled for testing."
    fi
}

# Main execution
check_prerequisites
backup
send_notification
delete_backups