#!/bin/bash

SOURCE_DIR="/home/dhruv/Github/mylinux"      # Directory to backup
BACKUP_DIR="/home/dhruv/Document"     # Where backups will be stored

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
    echo "Make backup directory"        
    mkdir "$BACKUP_DIR"
fi

# Generate backup filename with timestamp
TIMESTAMP=$(date +%H%M%S_%d%m%Y)
BACKUP_FILE="backup_${TIMESTAMP}.zip"

# Create the backup
echo "Starting backup process..."
zip -r "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" > backup.log

if [ $? -eq 0 ]; then
    echo "Backup completed: ${BACKUP_DIR}/${BACKUP_FILE}" 
else
    echo "Backup failed!"
    exit 1
fi
