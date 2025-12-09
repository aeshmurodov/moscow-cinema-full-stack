#!/bin/bash
set -e

# Create and activate venv
python3 -m venv venv
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
python dump_schema.py test.db test_dump.sql
python dump_schema.py stage.db stage_dump.sql

# Compare schemas
if ! diff -I '^--' -I '^$' test_dump.sql stage_dump.sql >/dev/null; then
    echo "Schemas differ; running migration..."

    flyway -url=jdbc:sqlite:stage.db \
           -locations=filesystem:db_schema/migrations \
           migrate
else
    echo "Schemas identical; no migration required"
fi

# Cleanup
rm test_dump.sql stage_dump.sql
deactivate
