FROM python:3.9-slim

# Installer curl et nettoyer les fichiers temporaires
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir torch==2.0.0+cpu -f https://download.pytorch.org/whl/torch_stable.html \
    && pip install --no-cache-dir -r requirements.txt
COPY . .
ENV TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ENV TELEGRAM_BOT_NAME=$TELEGRAM_BOT_NAME
RUN chmod +x entrypoint.sh
CMD ["./entrypoint.sh"]
