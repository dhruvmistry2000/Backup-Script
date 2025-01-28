#!/bin/bash
SOURCE_DIR="/home/dhruv/Github/mylinux"    # Directory to backup - source directory path  
BACKUP_DIR="/home/dhruv/Document"     # Where backups will be stored locally
REMOTE_NAME="gdrive"                  # Name of rclone remote
REMOTE_DIR="/backup"                  # Remote directory path

# Basic error checking
if [ -z "$SOURCE_DIR" ]; then
    echo "Missing source directory parameter"
    exit 1
fi

if [ -z "$BACKUP_DIR" ]; then
    echo "Missing backup directory parameter"
    exit 1
fi

# Create backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Making backup directory"        
    mkdir "$BACKUP_DIR"
fi

# Generate backup filename with timestamp
TIMESTAMP=$(date +%H%M%S_%d%m%Y)
BACKUP_FILE="backup_${TIMESTAMP}.zip"

# Create the local backup using zip
echo "Starting local backup process..."
zip -r "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" > local.log
if [ $? -eq 0 ]; then
    echo "Local Backup completed: ${BACKUP_DIR}/${BACKUP_FILE}" 
else
    echo "Local Backup failed!"
    exit 1
fi

# Copy backup to remote storage using rclone
echo "Starting remote backup process..."
rclone copy "${BACKUP_DIR}/${BACKUP_FILE}" "$REMOTE_NAME:$REMOTE_DIR" > remote.log
if [ $? -eq 0 ]; then
    echo "Remote Backup completed: ${BACKUP_DIR}/${BACKUP_FILE}" 
else
    echo "Remote Backup failed!"
    exit 1
fi
