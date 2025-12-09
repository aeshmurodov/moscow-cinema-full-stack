#!/bin/bash
set -e

# Create virtual environment
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Install SQL linter
pip install sqlfluff

# Run SQL linting in the current folder using the correct dialect
sqlfluff lint . --dialect sqlite

echo "SQL lint completed successfully."
