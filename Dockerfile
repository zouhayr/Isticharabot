FROM python:3.9-slim

# Installer curl et nettoyer les fichiers temporaires
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les fichiers
COPY requirements.txt . 

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt \
    -f https://download.pytorch.org/whl/torch_stable.html

COPY . .

# Définir les variables d'environnement
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_BOT_NAME
ENV TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
ENV TELEGRAM_BOT_NAME=${TELEGRAM_BOT_NAME}

# Assurer les permissions du script
RUN chmod +x entrypoint.sh

# Utiliser un utilisateur non-root
RUN useradd -m botuser
USER botuser

# Lancer le bot
CMD ["./entrypoint.sh"]

