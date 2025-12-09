#!/bin/bash
apt install python3-sqlcheck

find db_schema -name "*.sql" | xargs sqlcheck -f
if [ $? -ne 0 ]; then
    echo "Проверка безопасности SQL не удалась!"