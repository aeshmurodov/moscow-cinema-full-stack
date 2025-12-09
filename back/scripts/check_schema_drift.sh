#!/bin/bash
set -e

# Create venv only if it does not exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv || { echo "Failed to create venv"; exit 1; }
else
    echo "Virtual environment already exists. Skipping creation."
fi

# Activate venv
source venv/bin/activate

# Install SQL linter
pip install sqlfluff

# Run SQL linting in the current folder using the correct dialect
sqlfluff lint . --dialect sqlite

echo "SQL lint completed successfully."
