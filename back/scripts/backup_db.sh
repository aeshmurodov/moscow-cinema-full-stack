#!/bin/bash
# back/scripts/backup_db_sqlite.sh - Создание резервной копии SQLite в SQL-формате

# Определяем путь к базе данных (можно через переменную окружения или аргумент)
DB_FILE="${PROD_DB_PATH:-prod.db}"
BACKUP_DIR="backups"

# Создаем директорию для резервных копий, если её нет
mkdir -p "$BACKUP_DIR"

# Генерируем имя файла с датой
BACKUP_FILE="$BACKUP_DIR/prod_backup_$(date +%Y%m%d_%H%M%S).sql"

# Создаем полный дамп базы данных
sqlite3 "$DB_FILE" .dump > "$BACKUP_FILE"

# Проверяем успешность выполнения
if [ $? -eq 0 ]; then
    echo "Резервная копия создана: $BACKUP_FILE"
    echo "Размер: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "Ошибка при создании резервной копии!"
    exit 1
fi