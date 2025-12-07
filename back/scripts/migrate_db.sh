#!/bin/bash
# scripts/migrate_db_sqlite.sh
#!/bin/bash
# Начало вашего скрипта или отдельный шаг в TeamCity

# Устанавливаем sqlite3 если он не установлен
if ! command -v sqlite3 &> /dev/null; then
    echo "Установка sqlite3..."
    # Для Ubuntu/Debian
    apt-get update && apt-get install -y sqlite3
    # Или для CentOS/RHEL:
    # yum install -y sqlite
fi

# Проверяем установку
sqlite3 --version || echo "SQLite не установлен" && exit 1

# Далее ваш существующий код...

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