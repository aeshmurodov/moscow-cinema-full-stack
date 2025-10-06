FROM python:3.10-slim

WORKDIR /app

# Копируем requirements.txt из текущей (back) папки
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Копируем всё содержимое папки back (где лежит manage.py)
COPY . .

# Запускаем миграции и gunicorn
CMD python manage.py migrate --noinput && \
    python manage.py createsu && \
    python manage.py collectstatic --noinput && \
    gunicorn backend.wsgi:application --bind 0.0.0.0:8000