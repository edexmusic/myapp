FROM python:3.12-slim

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        curl \
        gnupg \
        ca-certificates \
        lsb-release && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER appuser

WORKDIR /app

COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser . .

EXPOSE 80

CMD ["python", "app.py"]
