#!/bin/bash
set -e

# If variables are not set, use defaults
DB_PATH="${STAGE_DB_PATH:-test.db}"           # path to your SQLite DB
BACKUP_DIR="${BACKUP_DIR:-backups}"           # backup folder
FILE_NAME="backup_$(date +%Y%m%d_%H%M%S).db" # backup file name
FULL_PATH="$BACKUP_DIR/$FILE_NAME"

# Ensure backup folder exists
mkdir -p "$BACKUP_DIR"

echo "=== Creating backup of SQLite DB $DB_PATH ==="

# Create backup using sqlite3
if command -v sqlite3 &> /dev/null; then
    sqlite3 "$DB_PATH" ".backup '$FULL_PATH'"
else
    # Fallback: simple file copy (not 100% safe if DB is in use)
    cp "$DB_PATH" "$FULL_PATH"
fi

# Check if backup was created
if [ -s "$FULL_PATH" ]; then
    echo "Backup created: $FULL_PATH"
else
    echo "Error creating backup!"
    exit 1
fi
