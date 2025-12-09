#!/bin/bash
set -e

# Если переменные не переданы, падаем (или используем дефолт)
HOST="${STAGE_DB_HOST:-db}"
USER="${STAGE_DB_USER:-postgres}"
NAME="${STAGE_DB_NAME:-cinema}"
PASS="${STAGE_DB_PASSWORD:-postgres}"

BACKUP_DIR="backups"
FILE_NAME="backup_$(date +%Y%m%d_%H%M%S).sql"
FULL_PATH="$BACKUP_DIR/$FILE_NAME"

mkdir -p "$BACKUP_DIR"

echo "=== Создание бэкапа БД $NAME ==="

# Запускаем pg_dump через докер, чтобы не зависеть от версии psql на аген
docker run --rm \
  -e PGPASSWORD="$PASS" \
  postgres:14 \
  pg_dump -h "$HOST" -U "$USER" -d "$NAME" -F p > "$FULL_PATH"

if [ -s "$FULL_PATH" ]; then
  echo "Бэкап создан: $FULL_PATH"
else
  echo "Ошибка создания бэкапа!"
  exit 1
fi