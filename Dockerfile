# Базовий образ з останнім Python
FROM python:3.12-slim

# Робоча директорія всередині контейнера
WORKDIR /app

# Встановлюємо залежності
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо увесь проєкт
COPY . .

# Контейнер відкриватиме порт 80
EXPOSE 80

# Команда запуску
CMD ["python", "app.py"]
