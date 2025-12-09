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

echo "=== Creating backup of SQLite DB $DB_PATH using Python ==="

python3 - <<EOF
import sqlite3
import shutil
import sys

src = "$DB_PATH"
dst = "$FULL_PATH"

try:
    conn = sqlite3.connect(src)
    with sqlite3.connect(dst) as backup_conn:
        conn.backup(backup_conn)
    conn.close()
except Exception as e:
    print(f"Error creating backup: {e}")
    sys.exit(1)
EOF

# Check if backup was created
if [ -s "$FULL_PATH" ]; then
    echo "Backup created successfully: $(realpath "$FULL_PATH")"
    cat "$FULL_PATH"
else
    echo "Error creating backup!"
    exit 1
fi
