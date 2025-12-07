#!/bin/bash
set -e

echo "[INFO] Creating virtual environment..."
python3 -m venv venv

echo "[INFO] Activating virtual environment..."
source venv/bin/activate

echo "[INFO] Installing sqlcheck..."
pip install --upgrade pip
pip install sqlcheck

find back/db_schema -name "*.sql" | xargs sqlcheck -f
if [ $? -ne 0 ]; then
    echo "Проверка безопасности SQL не удалась!"
    exit 1
fi
