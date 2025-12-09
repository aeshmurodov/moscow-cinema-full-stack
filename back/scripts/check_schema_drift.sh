#!/bin/bash
set -e

# Проверка переменных
if [ -z "$STAGE_DB_HOST" ]; then
  echo "Ошибка: Не заданы переменные окружения для STAGE БД (STAGE_DB_HOST и т.д.)"
  exit 1
fi

echo "=== [1/4] Запуск временной базы данных (Reference/Test) ==="
# Запускаем чистый Postgres на порту 5433, чтобы не конфликтовать с локальным 5432
docker run -d --name temp_reference_db \
  -e POSTGRES_USER=test_user \
  -e POSTGRES_PASSWORD=test_pass \
  -e POSTGRES_DB=test_db \
  -p 5433:5432 \
  postgres:14

echo "Ждем запуска БД..."
sleep 5

echo "=== [2/4] Накатывание миграций из кода на временную БД ==="
# Устанавливаем зависимости (если на агенте нет)
pip install -r back/requirements.txt

# Говорим Django использовать эту временную базу
export DATABASE_URL="postgres://test_user:test_pass@localhost:5433/test_db"

# Выполняем миграции -> теперь в temp_reference_db идеальная схема из твоего кода
python3 back/manage.py migrate

echo "=== [3/4] Запуск Liquibase Diff (Сравнение Code vs Stage) ==="
# --network host позволяет контейнеру liquibase видеть localhost агента (порт 5433)
docker run --rm --network host \
  -v $(pwd)/back:/liquibase/changelog \
  liquibase/liquibase:4.25.1 \
  --driver=org.postgresql.Driver \
  --url="jdbc:postgresql://${STAGE_DB_HOST}:5432/${STAGE_DB_NAME}" \
  --username="${STAGE_DB_USER}" \
  --password="${STAGE_DB_PASSWORD}" \
  --referenceUrl="jdbc:postgresql://localhost:5433/test_db" \
  --referenceUsername="test_user" \
  --referencePassword="test_pass" \
  diff

echo "=== [4/4] Очистка ==="
docker stop temp_reference_db
docker rm temp_reference_db