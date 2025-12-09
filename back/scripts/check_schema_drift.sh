#!/bin/bash
set -e

# Create virtual environment
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Install SQL linter
pip install sqlfluff

# Run SQL linting
sqlfluff lint db_schema

echo "SQL lint completed successfully."
