#!/bin/bash
set -e

# Create venv only if it does not exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv || { echo "Failed to create venv"; exit 1; }
else
    echo "Virtual environment already exists. Skipping creation."
fi

source venv/bin/activate

# Python script to dump schema
cat > dump_schema.py << 'EOF'
import sqlite3, sys

db = sys.argv[1]
out = sys.argv[2]

conn = sqlite3.connect(db)
cur = conn.cursor()

with open(out, "w") as f:
    for row in cur.execute("SELECT sql FROM sqlite_master WHERE sql NOT NULL"):
        f.write(row[0] + ";\n")

conn.close()
EOF

# Generate schema dumps
python dump_schema.py test.db test_dump.sqlsqlite3 test_db.db ".schema" > back/db_schema/current_schema.sql
