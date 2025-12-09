#!/bin/bash
set -e

# Paths
TEST_DB="test.db"
STAGE_DB="stage.db"
MIGRATIONS_DIR="back/db_schema/migrations"
SCHEMA_DIR="back/db_schema"
mkdir -p "$SCHEMA_DIR"

# Create venv if not exists
if [ ! -d "venv" ]; then
    echo "Creating Python venv..."
    python3 -m venv venv
fi
source venv/bin/activate

# Install sqlfluff for linting
pip install --quiet sqlfluff

# Lint all SQL files first
echo "=== Linting SQL files in $MIGRATIONS_DIR ==="
sqlfluff lint "$MIGRATIONS_DIR" --dialect sqlite

# Apply migrations to test DB
echo "=== Applying migrations to $TEST_DB ==="
for sql in "$MIGRATIONS_DIR"/*.sql; do
    echo "Applying $sql"
    python3 - <<EOF
import sqlite3
db = "$TEST_DB"
with sqlite3.connect(db) as conn:
    with open("$sql") as f:
        conn.executescript(f.read())
EOF
done

# Dump schemas
echo "=== Dumping schemas ==="
python3 - <<EOF
import sqlite3

def dump_schema(db_path, out_file):
    conn = sqlite3.connect(db_path)
    with open(out_file, "w") as f:
        for row in conn.execute("SELECT sql FROM sqlite_master WHERE sql NOT NULL"):
            f.write(row[0] + ";\n")
    conn.close()

dump_schema("$TEST_DB", "$SCHEMA_DIR/test_schema.sql")
dump_schema("$STAGE_DB", "$SCHEMA_DIR/stage_schema.sql")
EOF

# Compare schemas ignoring empty lines and comments
echo "=== Comparing schemas ==="
if diff -I '^--' -I '^$' "$SCHEMA_DIR/test_schema.sql" "$SCHEMA_DIR/stage_schema.sql" > /dev/null; then
    echo "Schemas are identical. No further action required."
else
    echo "Schemas differ! Proceeding with next steps..."

    # Example: backup stage DB
    BACKUP_DIR="backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/stage_backup_$(date +%Y%m%d_%H%M%S).db"
    python3 - <<EOF
import sqlite3
src = "$STAGE_DB"
dst = "$BACKUP_FILE"
conn = sqlite3.connect(src)
with sqlite3.connect(dst) as backup_conn:
    conn.backup(backup_conn)
conn.close()
EOF
    echo "Stage DB backed up to $BACKUP_FILE"

    # Here you can add further steps like applying migrations to stage
fi
