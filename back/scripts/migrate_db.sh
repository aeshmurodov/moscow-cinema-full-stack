#!/bin/bash
#!/bin/bash
# scripts/migrate_db_sqlite.sh

# Получаем схемы из SQLite баз
sqlite3 test.db ".schema" > test_dump.sql
sqlite3 stage.db ".schema" > stage_dump.sql

# Сравниваем, игнорируя комментарии и пустые строки
if ! diff -I '^--' -I '^$' test_dump.sql stage_dump.sql > /dev/null 2>&1; then
    echo "Схемы различаются; приступаем к миграции"
    
    # Применяем миграции через Flyway
    # Предполагается, что flyway и драйвер SQLite настроены
    flyway -url=jdbc:sqlite:stage.db \
           -user= \
           -password= \
           -locations=filesystem:db_schema/migrations \
           migrate
else
    echo "Схемы идентичны, миграция не требуется"
fi

# Очистка временных файлов
rm -f test_dump.sql stage_dump.sql