#!/bin/bash
python3 -m pip install sqlcheck

find db_schema -name "*.sql" | xargs sqlcheck -f
if [ $? -ne 0 ]; then
    echo "Проверка безопасности SQL не удалась!"
    exit 1
fi
