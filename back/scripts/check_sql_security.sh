#!/bin/bash
set -e

echo "[INFO] Creating virtual environment..."
python3 -m venv venv

echo "[INFO] Activating virtual environment..."
source venv/bin/activate

echo "[INFO] Installing sqlfluff..."
pip install --upgrade pip
pip install sqlfluff

echo "[INFO] Running SQL security/static analysis..."

sqlfluff lint --dialect sqlite back/db_schema

echo "[INFO] SQL security check passed!"
