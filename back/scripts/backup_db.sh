#!/bin/bash
set -e

# Path to your SQLite database
DB_PATH="test.db"

# Backup folder
BACKUP_DIR="backups"

# Backup file name
FILE_NAME="backup_$(date +%Y%m%d_%H%M%S).db"
FULL_PATH="$BACKUP_DIR/$FILE_NAME"

# Ensure backup folder exists
mkdir -p "$BACKUP_DIR"

echo "=== Creating backup of SQLite DB $DB_PATH ==="

# Create backup using sqlite3 if available
if command -v sqlite3 &> /dev/null; then
    sqlite3 "$DB_PATH" ".backup '$FULL_PATH'"
else
    # Fallback: simple file copy (not safe if DB is in use)
    cp "$DB_PATH" "$FULL_PATH"
fi

# Check if backup was created
if [ -s "$FULL_PATH" ]; then
    echo "Backup created: $FULL_PATH"
else
    echo "Error creating backup!"
    exit 1
fi
