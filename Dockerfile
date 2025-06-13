# Базовий образ з останнім Python
FROM python:3.12-slim

# Перейдемо на root користувача, щоб мати права на встановлення пакетів
USER root

# Оновлення системи та встановлення sudo
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        curl \
        gnupg \
        ca-certificates \
        lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Додамо нового користувача appuser та дамо йому sudo без пароля
RUN useradd -ms /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Перейдемо до цього користувача
USER appuser

# Робоча директорія всередині контейнера
WORKDIR /app

# Встановлюємо залежності
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо увесь проєкт
COPY --chown=appuser:appuser . .

# Контейнер відкриватиме порт 80
EXPOSE 80

# Команда запуску
CMD ["python", "app.py"]
