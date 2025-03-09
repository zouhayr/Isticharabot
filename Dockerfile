FROM python:3.9-slim

# Installer curl et nettoyer les fichiers temporaires
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les fichiers
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    -f https://download.pytorch.org/whl/torch_stable.html

# Copier les autres fichiers
COPY models/ ./models/
COPY credentials.yml ./
COPY entrypoint.sh .

# Assurer les permissions du script
RUN chmod +x entrypoint.sh

# Créer un répertoire temporaire avec permissions larges
RUN mkdir -p /tmp/rasa_logs && chmod -R 777 /tmp/rasa_logs

# Définir les variables d'environnement
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_BOT_NAME
ENV TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
ENV TELEGRAM_BOT_NAME=${TELEGRAM_BOT_NAME}

# Utiliser un utilisateur non-root
RUN useradd -m botuser
USER botuser

# Lancer le bot
CMD ["./entrypoint.sh"]
